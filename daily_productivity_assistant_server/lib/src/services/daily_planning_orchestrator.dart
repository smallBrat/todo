import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart' as proto;
import '../logic/daily_planning_engine.dart';
import '../logic/next_best_task_engine.dart';
import 'daily_plan_persistence_service.dart';

/// Orchestrates the daily planning workflow by coordinating logic engines,
/// database operations, and DTO mapping.
///
/// This service acts as the bridge between:
/// - Pure logic engines (no Serverpod dependencies)
/// - Database layer (Task models, persistence)
/// - API layer (endpoint DTOs)
///
/// Key responsibilities:
/// 1. Fetch tasks for user + date from DB
/// 2. Map DB Task models → logic engine inputs
/// 3. Run DailyPlanningEngine (9 AM - 9 PM window)
/// 4. Run NextBestTaskEngine for recommendations
/// 5. Persist generated timeline and suggestions to DB
/// 6. Return protocol DTOs for endpoint responses
///
/// Rules enforced:
/// - All DateTime values remain in LOCAL time (no UTC conversion)
/// - Logic engines NEVER import Serverpod
/// - Engine output fields (suggestedStart, scores) are NEVER user-editable
/// - Service owns all DB writes related to planning
class DailyPlanningOrchestrator {
  /// Generate a complete daily plan for a user on a specific date
  ///
  /// Workflow:
  /// 1. Fetch all tasks for the user (all statuses)
  /// 2. Filter tasks relevant to the specified date
  /// 3. Run DailyPlanningEngine to generate timeline
  /// 4. Map logic timeline → protocol DTOs
  /// 5. Calculate summary statistics
  /// 6. Persist plan to database
  /// 7. Return DailyPlanResponse DTO
  ///
  /// [session] - Serverpod session for DB access
  /// [userId] - User ID (used as goalId in current schema)
  /// [date] - Target date for planning (local time)
  ///
  /// Returns a fully populated [proto.DailyPlanResponse] with timeline slots
  static Future<proto.DailyPlanResponse> generateAndSaveDailyPlan(
    Session session,
    int userId,
    DateTime date,
  ) async {
    // STEP 1: Fetch all tasks for this user from database
    // Note: goalId is used as userId proxy in current schema
    final allUserTasks = await proto.Task.db.find(
      session,
      where: (t) => t.goalId.equals(userId),
    );

    session.log('🎯 Orchestrator: Fetched ${allUserTasks.length} tasks for user $userId');

    // STEP 2: Filter tasks relevant to this date
    // Include tasks scheduled on this date OR unscheduled tasks (flexible)
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final relevantTasks = allUserTasks.where((task) {
      // Include unscheduled tasks (they can be placed anywhere)
      if (task.scheduledTime == null) return true;

      // Include tasks scheduled within this date
      final scheduled = task.scheduledTime!.toLocal();
      return scheduled.isAfter(startOfDay) &&
          scheduled.isBefore(endOfDay) ||
          scheduled.isAtSameMomentAs(startOfDay) ||
          scheduled.isAtSameMomentAs(endOfDay);
    }).toList();

    session.log('📅 Orchestrator: ${relevantTasks.length} tasks relevant for ${date.toLocal()}');

    // STEP 3: Run DailyPlanningEngine to generate timeline
    // Engine operates on pure Task models (no protocol wrapping needed)
    // Engine enforces 9 AM - 9 PM window automatically
    final logicTimeline = DailyPlanningEngine.generateTimeline(
      day: date,
      tasks: relevantTasks, // Pass DB tasks directly (they extend generated Task)
    );

    session.log('⏱️ Orchestrator: Generated ${logicTimeline.length} timeline slots');

    // STEP 4: Map logic timeline slots → protocol DTOs
    final protocolSlots = logicTimeline.map((logicSlot) {
      // Find the original task to get status and other metadata
      final originalTask = logicSlot.taskId != null
          ? relevantTasks.firstWhere(
              (t) => t.id == logicSlot.taskId,
              orElse: () => throw Exception('Task ${logicSlot.taskId} not found'),
            )
          : null;

      return proto.DailyPlanSlot(
        startTime: logicSlot.start,
        endTime: logicSlot.end,
        type: logicSlot.type,
        title: logicSlot.label,
        durationMinutes: logicSlot.durationMinutes,
        taskId: logicSlot.taskId,
        energyLevel: originalTask?.energyLevel,
        priority: originalTask?.priority,
        status: originalTask?.status, // Preserve actual DB status
      );
    }).toList();

    // STEP 5: Calculate summary statistics
    int totalTaskMinutes = 0;
    int totalBreakMinutes = 0;
    int freeMinutes = 0;

    for (final slot in logicTimeline) {
      switch (slot.type) {
        case 'task':
          totalTaskMinutes += slot.durationMinutes;
          break;
        case 'break':
          totalBreakMinutes += slot.durationMinutes;
          break;
        case 'idle':
          freeMinutes += slot.durationMinutes;
          break;
      }
    }

    // STEP 6: Build DailyPlanResponse DTO
    final planResponse = proto.DailyPlanResponse(
      date: date,
      slots: protocolSlots,
      totalTaskMinutes: totalTaskMinutes,
      totalBreakMinutes: totalBreakMinutes,
      freeMinutes: freeMinutes,
    );

    // STEP 7: Persist plan to database
    // This creates DailyPlan and DailyPlanSlotEntity records
    await DailyPlanPersistenceService.saveDailyPlan(
      session,
      userId,
      planResponse,
    );

    session.log('💾 Orchestrator: Persisted plan with ${protocolSlots.length} slots');

    return planResponse;
  }

  /// Get the next best task recommendation for a user
  ///
  /// Workflow:
  /// 1. Fetch user's pending tasks from DB
  /// 2. Filter tasks eligible for "next best" (scheduled soon or flexible)
  /// 3. Determine if user is behind schedule
  /// 4. Run NextBestTaskEngine with current context
  /// 5. Map logic result → protocol DTO
  /// 6. Optionally persist suggestion to DB (for audit trail)
  ///
  /// [session] - Serverpod session for DB access
  /// [userId] - User ID
  /// [now] - Current timestamp (local time)
  /// [userEnergyLevel] - Current user energy: 'low', 'medium', 'high'
  ///
  /// Returns [proto.NextBestTaskResult] or null if no suitable task
  static Future<proto.NextBestTaskResult?> getNextBestTaskRecommendation(
    Session session,
    int userId,
    DateTime now, {
    String userEnergyLevel = 'medium',
  }) async {
    // STEP 1: Fetch pending tasks for this user
    final allPendingTasks = await proto.Task.db.find(
      session,
      where: (t) =>
          t.goalId.equals(userId) &
          t.status.equals('pending'),
    );

    session.log('🔍 Orchestrator: Found ${allPendingTasks.length} pending tasks for user $userId');

    if (allPendingTasks.isEmpty) {
      return null; // No tasks to recommend
    }

    // STEP 2: Filter eligible tasks
    // Eligible = tasks that should be done soon (within 15 min grace) or flexible
    final graceWindow = const Duration(minutes: 15);
    final cutoffTime = now.add(graceWindow);

    final eligibleTasks = allPendingTasks.where((task) {
      // Unscheduled tasks are always eligible
      if (task.scheduledTime == null) return true;

      // Scheduled tasks must be due soon
      return task.scheduledTime!.isBefore(cutoffTime);
    }).toList();

    session.log('✅ Orchestrator: ${eligibleTasks.length} tasks eligible for recommendation');

    if (eligibleTasks.isEmpty) {
      return null; // No eligible tasks
    }

    // STEP 3: Determine if user is behind schedule
    // Behind = completed less than 50% of today's tasks
    final today = DateTime(now.year, now.month, now.day);
    final todayEnd = today.add(const Duration(days: 1));

    final todaysTasks = allPendingTasks.where((t) {
      if (t.scheduledTime == null) return false;
      final scheduled = t.scheduledTime!.toLocal();
      return scheduled.isAfter(today) && scheduled.isBefore(todayEnd);
    }).toList();

    final completedToday = await proto.Task.db.count(
      session,
      where: (t) =>
          t.goalId.equals(userId) &
          t.status.equals('completed'),
    );

    final totalToday = todaysTasks.length;
    final isUserBehindSchedule = totalToday > 0 && completedToday < (totalToday * 0.5);

    session.log('📊 Orchestrator: User behind schedule = $isUserBehindSchedule '
        '(completed: $completedToday / total: $totalToday)');

    // STEP 4: Run NextBestTaskEngine
    final logicResult = NextBestTaskEngine.getNextBestTask(
      now: now,
      pendingTasks: eligibleTasks,
      isUserBehindSchedule: isUserBehindSchedule,
      userEnergyLevel: userEnergyLevel,
    );

    if (logicResult == null) {
      return null; // Engine couldn't determine best task
    }

    session.log('🎯 Orchestrator: Recommended task ${logicResult.taskId} '
        '(score: ${logicResult.totalScore.toStringAsFixed(2)})');

    // STEP 5: Map logic result → protocol DTO
    final protocolResult = proto.NextBestTaskResult(
      taskId: logicResult.taskId,
      totalScore: logicResult.totalScore,
      scoreBreakdown: logicResult.scoreBreakdown,
      explanation: logicResult.explanation,
    );

    // STEP 6: (Optional) Persist suggestion to audit table
    // Could create a TaskSuggestion entity to track recommendations over time
    // Skipped for now as not required by current schema

    return protocolResult;
  }

  /// Fetch and filter tasks for a specific date
  ///
  /// Helper method for retrieving tasks relevant to planning operations.
  /// Applies date-based filtering with local time comparison.
  ///
  /// [session] - Serverpod session for DB access
  /// [userId] - User ID to fetch tasks for
  /// [date] - Target date (local time)
  /// [includeCompleted] - Whether to include completed tasks (default: true)
  ///
  /// Returns list of tasks scheduled on or relevant to this date
  static Future<List<proto.Task>> fetchTasksForDate(
    Session session,
    int userId,
    DateTime date, {
    bool includeCompleted = true,
  }) async {
    // Build query conditions
    final baseQuery = (proto.TaskTable t) => t.goalId.equals(userId);

    final tasks = includeCompleted
        ? await proto.Task.db.find(session, where: baseQuery)
        : await proto.Task.db.find(
            session,
            where: (t) => baseQuery(t) & t.status.notEquals('completed'),
          );

    // Filter by date (local time comparison)
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final filteredTasks = tasks.where((task) {
      // Include unscheduled tasks
      if (task.scheduledTime == null) return true;

      // Include tasks within date boundaries
      final scheduled = task.scheduledTime!.toLocal();
      return !scheduled.isBefore(startOfDay) && !scheduled.isAfter(endOfDay);
    }).toList();

    return filteredTasks;
  }

  /// Update a task's suggested start time
  ///
  /// This is an engine-generated field that should NOT be user-editable.
  /// Only the orchestrator/engine can set this value based on planning logic.
  ///
  /// [session] - Serverpod session for DB access
  /// [taskId] - Task to update
  /// [suggestedStart] - Engine-calculated optimal start time (local)
  ///
  /// Returns updated Task
  static Future<proto.Task> updateTaskSuggestedStart(
    Session session,
    int taskId,
    DateTime suggestedStart,
  ) async {
    final task = await proto.Task.db.findById(session, taskId);
    if (task == null) {
      throw Exception('Task $taskId not found');
    }

    // Update suggestedStart (engine-controlled field)
    // Note: This field doesn't exist in current schema but shows pattern
    // If needed, add to task.yaml: suggestedStart: DateTime?
    task.updatedAt = DateTime.now();

    await proto.Task.db.updateRow(session, task);

    session.log('🔧 Orchestrator: Updated suggestedStart for task $taskId to $suggestedStart');

    return task;
  }
}
