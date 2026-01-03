// EXAMPLE REFACTORING: How to use DailyPlanningOrchestrator
//
// This file shows before/after examples of refactoring planning_endpoint.dart
// to use the new orchestrator service.
// ignore_for_file: unused_import, uri_does_not_exist, undefined_identifier, undefined_function, undefined_class, unused_local_variable, invalid_assignment

import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart' as proto;
import '../services/daily_planning_orchestrator.dart';

// ============================================================================
// EXAMPLE 1: generateAndSavePlan endpoint
// ============================================================================

// ❌ BEFORE: Endpoint contains orchestration logic
Future<proto.DailyPlanResponse> generateAndSavePlanOLD(
  Session session,
  int userId,
  DateTime date,
) async {
  // Manual task fetching
  final allTasks = await proto.Task.db.find(
    session,
    where: (t) => t.goalId.equals(userId),
  );

  // Manual date filtering
  final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
  final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
  final todayTasks = allTasks.where((task) {
    if (task.scheduledTime == null) return true;
    final s = task.scheduledTime!.toLocal();
    return !s.isBefore(startOfDay) && !s.isAfter(endOfDay);
  }).toList();

  // Manual engine invocation
  final timeline = DailyPlanningEngine.generateTimeline(
    day: date,
    tasks: todayTasks,
  );

  // Manual DTO mapping
  final planSlots = timeline.map((slot) {
    final originalTask = slot.taskId != null
        ? todayTasks.firstWhere((t) => t.id == slot.taskId)
        : null;
    return proto.DailyPlanSlot(
      startTime: slot.start,
      endTime: slot.end,
      type: slot.type,
      title: slot.label,
      durationMinutes: slot.durationMinutes,
      taskId: slot.taskId,
      energyLevel: originalTask?.energyLevel,
      priority: originalTask?.priority,
      status: originalTask?.status,
    );
  }).toList();

  // Manual statistics calculation
  int totalTaskMinutes = 0;
  int totalBreakMinutes = 0;
  int freeMinutes = 0;
  for (final slot in timeline) {
    switch (slot.type) {
      case 'task': totalTaskMinutes += slot.durationMinutes; break;
      case 'break': totalBreakMinutes += slot.durationMinutes; break;
      case 'idle': freeMinutes += slot.durationMinutes; break;
    }
  }

  // Manual response building
  final planResponse = proto.DailyPlanResponse(
    date: date,
    slots: planSlots,
    totalTaskMinutes: totalTaskMinutes,
    totalBreakMinutes: totalBreakMinutes,
    freeMinutes: freeMinutes,
  );

  // Manual persistence
  await DailyPlanPersistenceService.saveDailyPlan(
    session,
    userId,
    planResponse,
  );

  return planResponse;
}

// ✅ AFTER: Endpoint delegates to orchestrator
Future<proto.DailyPlanResponse> generateAndSavePlanNEW(
  Session session,
  int userId,
  DateTime date,
) async {
  // Single orchestrator call handles everything:
  // - Task fetching
  // - Date filtering
  // - Engine invocation
  // - DTO mapping
  // - Statistics calculation
  // - Persistence
  return await DailyPlanningOrchestrator.generateAndSaveDailyPlan(
    session,
    userId,
    date,
  );
}

// ============================================================================
// EXAMPLE 2: getNextBestTask endpoint
// ============================================================================

// ❌ BEFORE: Complex eligibility logic in endpoint
Future<proto.NextBestTaskResult?> getNextBestTaskOLD(
  Session session,
  int userId,
) async {
  final now = DateTime.now();
  
  // Manual fetching
  final allPendingTasks = await proto.Task.db.find(
    session,
    where: (t) => t.goalId.equals(userId) & t.status.equals('pending'),
  );

  if (allPendingTasks.isEmpty) return null;

  // Manual eligibility filtering
  final graceWindow = Duration(minutes: 15);
  final cutoffTime = now.add(graceWindow);
  final eligibleTasks = allPendingTasks.where((task) {
    if (task.scheduledTime == null) return true;
    return task.scheduledTime!.isBefore(cutoffTime);
  }).toList();

  if (eligibleTasks.isEmpty) return null;

  // Manual "behind schedule" calculation
  final today = DateTime(now.year, now.month, now.day);
  final todayEnd = today.add(Duration(days: 1));
  final todaysTasks = allPendingTasks.where((t) {
    if (t.scheduledTime == null) return false;
    final s = t.scheduledTime!.toLocal();
    return s.isAfter(today) && s.isBefore(todayEnd);
  }).toList();
  
  final completedCount = await proto.Task.db.count(
    session,
    where: (t) => t.goalId.equals(userId) & t.status.equals('completed'),
  );
  
  final isUserBehindSchedule = todaysTasks.length > 0 && 
      completedCount < (todaysTasks.length * 0.5);

  // Manual engine invocation
  final logicResult = NextBestTaskEngine.getNextBestTask(
    now: now,
    pendingTasks: eligibleTasks,
    isUserBehindSchedule: isUserBehindSchedule,
    userEnergyLevel: 'medium',
  );

  if (logicResult == null) return null;

  // Manual DTO mapping
  return proto.NextBestTaskResult(
    taskId: logicResult.taskId,
    totalScore: logicResult.totalScore,
    scoreBreakdown: logicResult.scoreBreakdown,
    explanation: logicResult.explanation,
  );
}

// ✅ AFTER: Orchestrator handles complexity
Future<proto.NextBestTaskResult?> getNextBestTaskNEW(
  Session session,
  int userId,
) async {
  // Single orchestrator call handles:
  // - Task fetching
  // - Eligibility filtering
  // - Behind schedule calculation
  // - Engine invocation
  // - DTO mapping
  return await DailyPlanningOrchestrator.getNextBestTaskRecommendation(
    session,
    userId,
    DateTime.now(),
    userEnergyLevel: 'medium', // Could come from user profile
  );
}

// ============================================================================
// EXAMPLE 3: Fetching tasks for a date
// ============================================================================

// ❌ BEFORE: Duplicate filtering logic across endpoints
Future<List<proto.Task>> getTasksForDateOLD(
  Session session,
  int userId,
  DateTime date,
) async {
  final allTasks = await proto.Task.db.find(
    session,
    where: (t) => t.goalId.equals(userId),
  );

  final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
  final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

  return allTasks.where((task) {
    if (task.scheduledTime == null) return true;
    final scheduled = task.scheduledTime!.toLocal();
    return !scheduled.isBefore(startOfDay) && !scheduled.isAfter(endOfDay);
  }).toList();
}

// ✅ AFTER: Reusable orchestrator helper
Future<List<proto.Task>> getTasksForDateNEW(
  Session session,
  int userId,
  DateTime date,
) async {
  return await DailyPlanningOrchestrator.fetchTasksForDate(
    session,
    userId,
    date,
    includeCompleted: true,
  );
}

// ============================================================================
// BENEFITS SUMMARY
// ============================================================================

/*
1. CODE REDUCTION
   - Before: ~80 lines per endpoint
   - After: ~5 lines per endpoint
   - Reduction: ~93%

2. TESTABILITY
   - Before: Must mock Session, Task.db, etc.
   - After: Test orchestrator in isolation, mock endpoints trivially

3. MAINTAINABILITY
   - Before: Change filtering logic → update 5 endpoints
   - After: Change filtering logic → update 1 orchestrator method

4. CONSISTENCY
   - Before: Different endpoints have slightly different filtering
   - After: All endpoints use same orchestrator logic

5. PERFORMANCE
   - Before: Potentially duplicate queries in same request
   - After: Orchestrator can cache/optimize queries

6. DEBUGGING
   - Before: Log statements scattered across endpoints
   - After: Centralized orchestrator logging (🎯 📅 ⏱️ 💾 emojis)

7. SEPARATION OF CONCERNS
   - Endpoints: Validate input, handle HTTP, format responses
   - Orchestrator: Business logic, coordination, DB access
   - Engines: Pure algorithms, testable without framework
*/
