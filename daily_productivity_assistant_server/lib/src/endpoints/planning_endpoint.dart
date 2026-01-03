import 'package:collection/collection.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart' as proto;
import '../logic/next_best_task_engine.dart';
import '../logic/next_best_task_result.dart' as logic;
import '../logic/daily_planning_engine.dart';
import '../services/daily_plan_persistence_service.dart';
import '../services/daily_closure_service.dart';


/// Endpoint for planning and task recommendation functionality
class PlanningEndpoint extends Endpoint {
  /// Gets the next best task recommendation for the authenticated user
  ///
  /// Returns null if no suitable task is available, no plan exists, or user is not authenticated.
  ///
  /// The endpoint is **plan-aware**:
  /// 1. Fetches today's DailyPlan
  /// 2. Extracts eligible tasks from plan slots (started or imminent)
  /// 3. Filters pending tasks to only those in the eligible set
  /// 4. Passes filtered tasks to NextBestTaskEngine for scoring
  /// 5. Returns the recommended task with plan-aware explanation
  ///
  /// Rules:
  /// - Only considers tasks in today's plan
  /// - Time-gated: slot.startTime <= now + 15 minutes
  /// - Scoring still decides the winner (priority, urgency, energy, focus)
  /// - Plan defines candidates, engine decides the best
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user (in production, get from session.auth)
  Future<proto.NextBestTaskResult?> getNextBestTask(
    Session session,
    int userId,
  ) async {
    // STEP 1: Get current time
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // STEP 2: Generate today's plan (fresh, with all slots)
    // We generate fresh rather than retrieving cached to ensure slots are populated
    final proto.DailyPlanResponse? planResponse = await getDailyPlan(session, today);
    
    // If no plan exists, return null
    if (planResponse == null) {
      print('ℹ️ No plan found for today, cannot recommend');
      return null;
    }

    // STEP 3: Extract task IDs from plan (all tasks scheduled for today)
    final allTaskIds = planResponse.slots
        .where((slot) => slot.taskId != null) // Only task slots
        .map((slot) => slot.taskId!)
        .toSet();
    
    // If no task slots in plan, return null
    if (allTaskIds.isEmpty) {
      return null;
    }

    // STEP 4: Fetch pending tasks from today's plan
    // These are candidates for recommendation
    final allPendingTasks = await proto.Task.db.find(
      session,
      where: (t) => t.status.equals('pending'),
    );
    
    final eligibleTasks = allPendingTasks
        .where((task) => allTaskIds.contains(task.id))
        .toList();
    
    // STEP 4a: Filter to imminent/started tasks (within 15 minutes)
    // This ensures we recommend time-appropriate tasks first
    final imminentTasks = eligibleTasks.where((task) {
      if (task.scheduledTime == null) return false;
      
      final scheduledTime = task.scheduledTime!;
      final scheduledLocal = scheduledTime.isUtc ? scheduledTime.toLocal() : scheduledTime;
      final minutesUntilStart = scheduledLocal.difference(now).inMinutes;
      
      // Task is imminent if it starts now or within the next 15 minutes
      return minutesUntilStart >= -5 && minutesUntilStart <= 15;
    }).toList();
    
    print('🔍 Planning: Found ${eligibleTasks.length} eligible tasks, ${imminentTasks.length} are imminent');

    // Use imminent tasks if available, otherwise consider all eligible tasks
    final tasksForRecommendation = imminentTasks.isNotEmpty ? imminentTasks : eligibleTasks;
    
    // If no pending tasks in plan, check if any in-progress tasks can be resumed
    if (tasksForRecommendation.isEmpty) {
      print('⚠️ No ${imminentTasks.isNotEmpty ? 'eligible' : 'pending'} tasks found. Checking for in-progress tasks...');
      final inProgressTasks = await proto.Task.db.find(
        session,
        where: (t) => t.status.equals('in_progress'),
      );
      
      final resumableTasks = inProgressTasks
          .where((task) => allTaskIds.contains(task.id))
          .toList();
      
      // Filter in-progress tasks to imminent ones
      final imminentInProgress = resumableTasks.where((task) {
        if (task.scheduledTime == null) return true; // In-progress without time is resumable
        
        final scheduledTime = task.scheduledTime!;
        final scheduledLocal = scheduledTime.isUtc ? scheduledTime.toLocal() : scheduledTime;
        final minutesUntilStart = scheduledLocal.difference(now).inMinutes;
        
        return minutesUntilStart >= -5 && minutesUntilStart <= 15;
      }).toList();
      
      final tasksToResume = imminentInProgress.isNotEmpty ? imminentInProgress : resumableTasks;
      
      if (tasksToResume.isEmpty) {
        print('ℹ️ No pending or in-progress tasks available for recommendation');
        return null;
      }
      
      // Recommend from in-progress tasks (user can resume)
      return _getRecommendationFromTasks(
        now: now,
        tasks: tasksToResume,
        taskIdsInPlan: allTaskIds,
        planResponse: planResponse,
        session: session,
      );
    }

    // STEP 5: Determine if user is behind schedule
    // Count completed vs total tasks in today's plan
    final completedTasks = planResponse.slots
        .where((slot) => slot.status == 'completed')
        .length;
    final totalTasks = planResponse.slots
        .where((slot) => slot.taskId != null)
        .length;
    
    // User is behind if they've completed less than 50% of their planned tasks
    final isUserBehindSchedule = totalTasks > 0 && 
        completedTasks < (totalTasks * 0.5);

    // STEP 6: Call the recommendation engine with time-filtered tasks
    final logic.NextBestTaskResult? recommendation = NextBestTaskEngine.getNextBestTask(
      now: now,
      pendingTasks: tasksForRecommendation,
      isUserBehindSchedule: isUserBehindSchedule,
      // TODO: Replace with real user energy level from context/profile
      userEnergyLevel: 'medium',
    );
    
    // STEP 7: Enhance explanation to mention plan context
    if (recommendation != null) {
      final enhancedExplanation = 
          'This task is scheduled in your plan and ${recommendation.explanation.substring(0, 1).toLowerCase()}${recommendation.explanation.substring(1)}';
      
      print('💡 NextBestTask recommendation: Task ${recommendation.taskId}');
      
      return proto.NextBestTaskResult(
        taskId: recommendation.taskId,
        totalScore: recommendation.totalScore,
        scoreBreakdown: recommendation.scoreBreakdown,
        explanation: enhancedExplanation,
      );
    }

    // No recommendation available
    return null;
  }

  /// Helper: Get recommendation from a list of eligible tasks
  Future<proto.NextBestTaskResult?> _getRecommendationFromTasks({
    required DateTime now,
    required List<proto.Task> tasks,
    required Set<int> taskIdsInPlan,
    required proto.DailyPlanResponse planResponse,
    required Session session,
  }) async {
    if (tasks.isEmpty) return null;

    // Determine if user is behind schedule
    final completedTasks = planResponse.slots
        .where((slot) => slot.status == 'completed')
        .length;
    final totalTasks = planResponse.slots
        .where((slot) => slot.taskId != null)
        .length;
    
    final isUserBehindSchedule = totalTasks > 0 && 
        completedTasks < (totalTasks * 0.5);

    // Call recommendation engine
    final logic.NextBestTaskResult? recommendation = NextBestTaskEngine.getNextBestTask(
      now: now,
      pendingTasks: tasks,
      isUserBehindSchedule: isUserBehindSchedule,
      userEnergyLevel: 'medium',
    );

    if (recommendation != null) {
      final enhancedExplanation = 
          'Resume this task to make progress toward your daily goal.';
      
      print('💡 NextBestTask recommendation (from in-progress): Task ${recommendation.taskId}');
      
      return proto.NextBestTaskResult(
        taskId: recommendation.taskId,
        totalScore: recommendation.totalScore,
        scoreBreakdown: recommendation.scoreBreakdown,
        explanation: enhancedExplanation,
      );
    }

    return null;
  }

  /// Gets today's timeline with all tasks scheduled
  ///
  /// Returns a list of timeline slots representing the planned day
  /// with tasks, breaks, and idle time.
  Future<List<proto.DailyTimelineSlot>> getTodayTimeline(
    Session session,
  ) async {
    // Fetch all pending tasks
    final tasks = await proto.Task.db.find(
      session,
      where: (t) => t.status.equals('pending'),
    );

    // Generate timeline (returns logic.DailyTimelineSlot)
    final timeline = DailyPlanningEngine.generateTimeline(
      day: DateTime.now(),
      tasks: tasks,
    );

    // Map logic timeline slots to protocol DTOs
    return timeline.map((slot) {
      return proto.DailyTimelineSlot(
        start: slot.start,
        end: slot.end,
        taskId: slot.taskId,
        label: slot.label,
        type: slot.type,
      );
    }).toList();
  }

  /// Gets the full daily plan for a given date as a response DTO
  ///
  /// Returns a structured [DailyPlanResponse] containing:
  /// - Ordered list of time slots (tasks, breaks, idle)
  /// - Summary statistics (task minutes, break minutes, free minutes)
  ///
  /// [session] - Serverpod session for database access
  /// [date] - The date to plan for
  Future<proto.DailyPlanResponse> getDailyPlan(
    Session session,
    DateTime date,
  ) async {
    // Debug: log incoming date
    try { session.log('getDailyPlan date=${date.toIso8601String()}'); } catch (_) {}
    // STEP 1: Fetch all tasks for the given date (including completed ones)
    final allTasks = await proto.Task.db.find(
      session,
    );
    try { session.log('getDailyPlan totalTaskCount=${allTasks.length}'); } catch (_) {}

    // Filter tasks for the specified date (scheduled on that date or unscheduled)
    // Normalize to day boundaries: startOfDay (inclusive) to endOfDay (exclusive)
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    session.log('START_OF_DAY=$startOfDay END_OF_DAY=$endOfDay');
    
    for (final task in allTasks) {
      session.log(
        'TASK id=${task.id} title=${task.title} '
        'scheduledTime=${task.scheduledTime} '
        'isUtc=${task.scheduledTime?.isUtc}',
      );
    }

    final todayTasks = allTasks.where((task) {
      if (task.scheduledTime == null) {
        return true; // Unscheduled tasks are available all day
      }
      final taskTime = task.scheduledTime!.toLocal();
      // Compare date components only (timezone-safe)
      return taskTime.year == startOfDay.year &&
             taskTime.month == startOfDay.month &&
             taskTime.day == startOfDay.day;
    }).toList();
    try { session.log('getDailyPlan filteredTodayTasks=${todayTasks.length}'); } catch (_) {}

    // STEP 2: Generate the timeline using the planning engine
    final timeline = DailyPlanningEngine.generateTimeline(
      day: date, 
      tasks: todayTasks,
    );
    final taskSlotCount = timeline.where((s) => s.type == 'task').length;
    try { session.log('getDailyPlan timelineSlots=${timeline.length}, taskSlots=$taskSlotCount'); } catch (_) {}

    // STEP 3: Convert engine output (List<logic.DailyTimelineSlot>) to response DTO (List<proto.DailyPlanSlot>)
    final planSlots = timeline.map((slot) {
      // Find the original task if this is a task slot
      final originalTask = slot.type == 'task' && slot.taskId != null
          ? todayTasks.firstWhereOrNull((t) => t.id == slot.taskId)
          : null;

      // 🔍 DEBUG LOG: Verify task status from DB
      if (originalTask != null) {
        session.log('📋 Task ${originalTask.id} (${originalTask.title}): DB status="${originalTask.status}"');
      }

      // Normalize status vocabulary to canonical values used by the app
      final normalizedStatus = _normalizeStatus(originalTask?.status);

      return proto.DailyPlanSlot(
        startTime: slot.start,
        endTime: slot.end,
        type: slot.type,
        title: slot.label,
        durationMinutes: slot.durationMinutes,
        taskId: slot.taskId,
        energyLevel: originalTask?.energyLevel,
        priority: originalTask?.priority,
        status: normalizedStatus, // ✅ Canonical status for clients
      );
    }).toList();

    // STEP 4: Compute summary statistics
    int totalTaskMinutes = 0;
    int totalBreakMinutes = 0;
    int freeMinutes = 0;

    for (final slot in timeline) {
        final int minutes = slot.durationMinutes.toInt();
      switch (slot.type) {
        case 'task':
          totalTaskMinutes += minutes;
          break;
        case 'break':
          totalBreakMinutes += minutes;
          break;
        case 'idle':
          freeMinutes += minutes;
          break;
      }
    }

    // STEP 5: Return the complete daily plan response
    return proto.DailyPlanResponse(
      date: date,
      slots: planSlots,
      totalTaskMinutes: totalTaskMinutes,
      totalBreakMinutes: totalBreakMinutes,
      freeMinutes: freeMinutes,
    );
  }

  /// Generates and saves a daily plan for a specific date
  ///
  /// This method combines plan generation with database persistence:
  /// 1. Generates the plan using the planning engine
  /// 2. Saves the plan and all slots to the database
  /// 3. Returns the persisted DailyPlan entity
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user for whom to generate the plan
  /// [date] - The date to plan for
  Future<proto.DailyPlanResponse> generateAndSavePlan(
    Session session,
    int userId,
    DateTime date,
  ) async {
    // STEP 1: Generate the plan using existing logic
    final planResponse = await getDailyPlan(session, date);

    // STEP 2: Persist the plan to the database (ensure idempotency)
    await DailyPlanPersistenceService.getOrCreateDailyPlan(
      session,
      userId,
      planResponse,
    );

    // STEP 3: Return the generated response DTO (client-facing)
    return planResponse;
  }

  /// Retrieves a saved daily plan from the database
  ///
  /// Returns null if no plan exists for the specified date.
  ///
  /// Dev/demo feature: Seeds sample tasks ONLY if no tasks exist for the user.
  /// Once any task (pending OR completed) exists, seeding is permanently disabled.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [date] - The date to retrieve the plan for
  Future<proto.DailyPlanResponse?> getSavedPlan(
    Session session,
    int userId,
    DateTime date,
  ) async {
    try { session.log('getSavedPlan date=${date.toIso8601String()}, userId=$userId'); } catch (_) {}
    // Check if ANY tasks exist for this user (across all dates and statuses)
    // We use goalId as a proxy for userId in this demo (all tasks have goalId=1 for demo user)
    final userTasks = await proto.Task.db.find(
      session,
      where: (t) => t.goalId.equals(userId),
    );

    // Deduplicate by title (case-insensitive) for this date before proceeding
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final tasksForDate = userTasks.where((task) {
      if (task.scheduledTime == null) return true;
      final scheduled = task.scheduledTime!;
      return !scheduled.isBefore(startOfDay) && !scheduled.isAfter(endOfDay);
    }).toList();

    final Map<String, List<proto.Task>> tasksByTitle = {};
    for (final task in tasksForDate) {
      final key = task.title.trim().toLowerCase();
      tasksByTitle.putIfAbsent(key, () => []).add(task);
    }

    final duplicates = <proto.Task>[];
    for (final entry in tasksByTitle.entries) {
      final list = entry.value;
      if (list.length <= 1) continue;

      list.sort((a, b) {
        int statusRank(String s) => (s.toLowerCase() == 'completed' || s.toLowerCase() == 'done') ? 1 : 0;
        final rankDiff = statusRank(b.status) - statusRank(a.status);
        if (rankDiff != 0) return rankDiff;
        final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      // Keep first, delete rest
      duplicates.addAll(list.skip(1));
    }

    for (final task in duplicates) {
      try {
        await proto.Task.db.deleteRow(session, task);
      } catch (e) {
        try { session.log('Failed to delete duplicate task id=${task.id}: $e'); } catch (_) {}
      }
    }

    if (duplicates.isNotEmpty) {
      try { session.log('Deduplicated ${duplicates.length} duplicate tasks by title for user $userId on ${date.toIso8601String()}'); } catch (_) {}
    }

    // Dev/demo seeding: DISABLED - user controls task creation via app
    // if (userTasks.isEmpty) {
    //   try { session.log('No tasks found for user $userId, seeding demo tasks'); } catch (_) {}
    //   await _seedDemoTasks(session, userId, date);
    // }

    // Generate and return the plan
    return await generateAndSavePlan(session, userId, date);
  }

  /// Deletes a saved daily plan
  ///
  /// [session] - Serverpod session for database access
  /// [planId] - ID of the plan to delete
  Future<void> deleteSavedPlan(
    Session session,
    int planId,
  ) async {
    await DailyPlanPersistenceService.deleteDailyPlan(session, planId);
  }

  /// Closes a day by marking pending tasks as missed and creating summary
  ///
  /// This endpoint:
  /// 1. Marks all remaining 'pending' tasks in today's plan as 'missed'
  /// 2. Computes daily summary statistics
  /// 3. Persists DailySummary as historical record
  /// 4. DailyPlan remains frozen (never mutated)
  ///
  /// Rules:
  /// - Day ends at 9:00 PM (fixed cutoff)
  /// - Tasks are marked missed, not deleted
  /// - Plan and slots remain unchanged
  /// - Summary is derived data, not editable
  /// - Idempotent: can be called multiple times safely
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [date] - The date to close (defaults to today if not specified)
  Future<proto.DailySummary?> closeDay(
    Session session,
    int userId,
    DateTime? date,
  ) async {
    final targetDate = date ?? DateTime.now();
    return await DailyClosureService.closeDay(session, userId, targetDate);
  }

  /// Gets the DailySummary for a specific date
  ///
  /// Returns null if day has not been closed yet.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [date] - The date to retrieve summary for
  Future<proto.DailySummary?> getDailySummary(
    Session session,
    int userId,
    DateTime date,
  ) async {
    return await DailyClosureService.getDailySummary(session, userId, date);
  }

  /// Gets DailySummary for a date range
  ///
  /// Useful for weekly/monthly reports.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [startDate] - Start of date range (inclusive)
  /// [endDate] - End of date range (inclusive)
  Future<List<proto.DailySummary>> getDailySummaryRange(
    Session session,
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await DailyClosureService.getDailySummaryRange(
      session,
      userId,
      startDate,
      endDate,
    );
  }

  /// Updates the status of a task
  ///
  /// Validates that the status is one of: "todo", "in_progress", "done"
  /// Updates the task in the database.
  ///
  /// Throws an Exception if the task is not found or status is invalid.
  ///
  /// [session] - Serverpod session for database access
  /// [taskId] - ID of the task to update
  /// [status] - New status: "todo", "in_progress", or "done"
  Future<void> updateTaskStatus(
    Session session,
    int taskId,
    String status,
  ) async {
    // Accept legacy and canonical values, then normalize to canonical
    const accepted = ['todo', 'in_progress', 'done', 'pending', 'completed', 'skipped'];
    if (!accepted.contains(status)) {
      throw Exception(
        'Invalid status: $status. Must be one of: pending, in_progress, completed, skipped (or legacy: todo, done)',
      );
    }

    // Find the task
    final task = await proto.Task.db.findById(session, taskId);
    if (task == null) {
      throw Exception('Task not found with id: $taskId');
    }

    // Normalize and persist canonical value
    task.status = _normalizeStatus(status) ?? 'pending';
    await proto.Task.db.updateRow(session, task);
  }

  /// Maps any legacy status to canonical values used across the app
  String? _normalizeStatus(String? s) {
    if (s == null) return null;
    switch (s.toLowerCase()) {
      case 'todo':
        return 'pending';
      case 'done':
        return 'completed';
      case 'pending':
      case 'in_progress':
      case 'completed':
      case 'skipped':
      case 'missed':
        return s.toLowerCase();
      default:
        return 'pending';
    }
  }

  /// Seeds demo tasks for development/demo purposes.
  ///
  /// Inserts 3-5 sample tasks with realistic titles and properties.
  /// Runs only when no tasks exist for the user.
  /// Each task includes all required fields (title, status, priority, energy, duration).
    /// [userId] - User ID (used as goalId for demo tasks)
  ///
  /// [session] - Serverpod session for database access
  /// [date] - The date to schedule these tasks for
  // ignore: unused_element
  Future<void> _seedDemoTasks(Session session, int userId, DateTime date) async {
    // Normalize to day to guarantee times within 9AM-9PM window
    final d = DateTime(date.year, date.month, date.day);
    final t0930 = DateTime(d.year, d.month, d.day, 9, 30);
    final t1100 = DateTime(d.year, d.month, d.day, 11, 0);
    final t1400 = DateTime(d.year, d.month, d.day, 14, 0);
    final t1600 = DateTime(d.year, d.month, d.day, 16, 0);
    final t1700 = DateTime(d.year, d.month, d.day, 17, 0);

    final demoTasks = [
      proto.Task(
        goalId: userId,
        title: 'Morning workout',
        status: 'pending',
        estimatedDuration: 60,
        priority: 'high',
        energyLevel: 'high',
        scheduledTime: t0930,
      ),
      proto.Task(
        goalId: userId,
        title: 'Deep work session',
        status: 'pending',
        estimatedDuration: 120,
        priority: 'high',
        energyLevel: 'medium',
        scheduledTime: t1100,
      ),
      proto.Task(
        goalId: userId,
        title: 'Review goals',
        status: 'pending',
        estimatedDuration: 30,
        priority: 'medium',
        energyLevel: 'high',
        scheduledTime: t1400,
      ),
      proto.Task(
        goalId: userId,
        title: 'Team sync meeting',
        status: 'pending',
        estimatedDuration: 45,
        priority: 'medium',
        energyLevel: 'medium',
        scheduledTime: t1600,
      ),
      proto.Task(
        goalId: userId,
        title: 'Plan tomorrow',
        status: 'pending',
        estimatedDuration: 20,
        priority: 'low',
        energyLevel: 'medium',
        scheduledTime: t1700,
      ),
    ];

    // Fetch existing tasks for this user on this date to avoid duplicates (case-insensitive title match)
    final startOfDay = DateTime(d.year, d.month, d.day, 0, 0, 0);
    final endOfDay = DateTime(d.year, d.month, d.day, 23, 59, 59);
    final existingTasksAll = await proto.Task.db.find(
      session,
      where: (t) => t.goalId.equals(userId),
    );
    final existingTasks = existingTasksAll.where((task) {
      if (task.scheduledTime == null) return true; // unscheduled tasks count as existing
      final scheduled = task.scheduledTime!;
      return !scheduled.isBefore(startOfDay) && !scheduled.isAfter(endOfDay);
    }).toList();
    final existingTitles = existingTasks
        .map((t) => t.title.trim().toLowerCase())
        .toSet();

    final tasksToInsert = demoTasks
        .where((task) => !existingTitles.contains(task.title.trim().toLowerCase()))
        .toList();

    if (tasksToInsert.isEmpty) {
      try { session.log('Seed skipped: all demo titles already exist for user $userId on ${d.toIso8601String()}'); } catch (_) {}
      return;
    }

    // Insert all demo tasks
    for (final task in tasksToInsert) {
      await proto.Task.db.insertRow(session, task);
    }
    try { session.log('Seeded demo tasks: ${tasksToInsert.length}'); } catch (_) {}
  }
}
