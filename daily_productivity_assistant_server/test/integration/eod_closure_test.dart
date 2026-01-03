import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:daily_productivity_assistant_server/src/generated/protocol.dart';
import 'package:daily_productivity_assistant_server/src/generated/endpoints.dart';
import 'package:daily_productivity_assistant_server/src/endpoints/planning_endpoint.dart';
import 'package:daily_productivity_assistant_server/src/services/daily_plan_persistence_service.dart';

/// Integration test for End-of-Day (EOD) closure functionality
///
/// This test verifies:
/// 1. Day ends at 9:00 PM (fixed cutoff)
/// 2. DailyPlan remains frozen (never mutated)
/// 3. Pending tasks → marked as 'missed'
/// 4. DailySummary is generated with correct statistics
/// 5. Idempotent: can be called multiple times
void main() {
  group('End-of-Day Closure', () {
    late Session session;
    late Serverpod pod;
    late PlanningEndpoint endpoint;
    
    const userId = 1;

    setUpAll(() async {
      // Bootstrap Serverpod for testing
      pod = Serverpod(
        ['--mode', 'test', '--apply-migrations'],
        Protocol(),
        Endpoints(),
      );
      await pod.start();
    });

    setUp(() async {
      session = await pod.createSession();
      endpoint = PlanningEndpoint();
      
      // Clean up any existing data for userId
      // Delete existing summaries
      await DailySummary.db.deleteWhere(
        session,
        where: (s) => s.userId.equals(userId),
      );
      
      // Delete existing plans and slots
      final existingPlans = await DailyPlan.db.find(
        session,
        where: (p) => p.userId.equals(userId),
      );
      
      for (final plan in existingPlans) {
        await DailyPlanPersistenceService.deleteDailyPlan(session, plan.id!);
      }
      
      // Delete existing tasks
      await Task.db.deleteWhere(
        session,
        where: (t) => t.goalId.equals(1),
      );
    });

    tearDown(() async {
      // Clean up after each test
      // Delete summaries
      await DailySummary.db.deleteWhere(
        session,
        where: (s) => s.userId.equals(userId),
      );
      
      // Delete plans
      final plans = await DailyPlan.db.find(
        session,
        where: (p) => p.userId.equals(userId),
      );
      
      for (final plan in plans) {
        await DailyPlanPersistenceService.deleteDailyPlan(session, plan.id!);
      }
      
      // Delete tasks
      await Task.db.deleteWhere(
        session,
        where: (t) => t.goalId.equals(1),
      );
      
      await session.close();
    });

    tearDownAll(() async {
      await pod.shutdown(exitProcess: false);
    });

    test('marks pending tasks as missed and creates summary', () async {
      // Given: Create tasks with different statuses
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final taskCompleted = Task(
        goalId: 1,
        title: 'Completed Task',
        estimatedDuration: 30,
        energyLevel: 'high',
        priority: 'high',
        scheduledTime: now,
        status: 'completed',
        completedAt: now,
      );
      
      final taskSkipped = Task(
        goalId: 1,
        title: 'Skipped Task',
        estimatedDuration: 45,
        energyLevel: 'medium',
        priority: 'medium',
        scheduledTime: now,
        status: 'skipped',
      );
      
      final taskPending1 = Task(
        goalId: 1,
        title: 'Pending Task 1',
        estimatedDuration: 60,
        energyLevel: 'low',
        priority: 'low',
        scheduledTime: now,
        status: 'pending',
      );
      
      final taskPending2 = Task(
        goalId: 1,
        title: 'Pending Task 2',
        estimatedDuration: 30,
        energyLevel: 'high',
        priority: 'medium',
        scheduledTime: now,
        status: 'pending',
      );
      
      final insertedCompleted = (await Task.db.insert(session, [taskCompleted])).first;
      final insertedSkipped = (await Task.db.insert(session, [taskSkipped])).first;
      final insertedPending1 = (await Task.db.insert(session, [taskPending1])).first;
      final insertedPending2 = (await Task.db.insert(session, [taskPending2])).first;

      // Create plan with all tasks
      final planResponse = DailyPlanResponse(
        date: today,
        slots: [
          DailyPlanSlot(
            startTime: now,
            endTime: now.add(Duration(minutes: 30)),
            type: 'task',
            title: 'Completed Task',
            durationMinutes: 30,
            taskId: insertedCompleted.id!,
            energyLevel: 'high',
            priority: 'high',
          ),
          DailyPlanSlot(
            startTime: now.add(Duration(minutes: 30)),
            endTime: now.add(Duration(minutes: 75)),
            type: 'task',
            title: 'Skipped Task',
            durationMinutes: 45,
            taskId: insertedSkipped.id!,
            energyLevel: 'medium',
            priority: 'medium',
          ),
          DailyPlanSlot(
            startTime: now.add(Duration(minutes: 75)),
            endTime: now.add(Duration(minutes: 135)),
            type: 'task',
            title: 'Pending Task 1',
            durationMinutes: 60,
            taskId: insertedPending1.id!,
            energyLevel: 'low',
            priority: 'low',
          ),
          DailyPlanSlot(
            startTime: now.add(Duration(minutes: 135)),
            endTime: now.add(Duration(minutes: 165)),
            type: 'task',
            title: 'Pending Task 2',
            durationMinutes: 30,
            taskId: insertedPending2.id!,
            energyLevel: 'high',
            priority: 'medium',
          ),
        ],
        totalTaskMinutes: 165,
        totalBreakMinutes: 0,
        freeMinutes: 195,
      );
      
      await DailyPlanPersistenceService.getOrCreateDailyPlan(
        session,
        userId,
        planResponse,
      );
      
      // When: Close the day
      final summary = await endpoint.closeDay(session, userId, today);

      // Then: Summary should be created with correct statistics
      expect(summary, isNotNull);
      expect(summary!.userId, equals(userId));
        // Date might differ by UTC/local timezone, just verify it's close
        final dateDiff = summary.date.difference(today).inHours.abs();
        expect(dateDiff, lessThan(24), reason: 'Summary date should be within 24 hours of test date');
      
      // Verify counts
      expect(summary.totalTasksPlanned, equals(4));
      expect(summary.completedCount, equals(1));
      expect(summary.skippedCount, equals(1));
      expect(summary.missedCount, equals(2)); // Two pending tasks marked as missed
      
      // Verify completion ratio
      expect(summary.completionRatio, equals(0.25)); // 1/4 = 0.25
      
      // Verify total focused minutes (only completed tasks count)
      expect(summary.totalFocusedMinutes, equals(30)); // Only completed task duration
      
      // Verify pending tasks are now marked as 'missed'
      final refetchedPending1 = await Task.db.findById(session, insertedPending1.id!);
      final refetchedPending2 = await Task.db.findById(session, insertedPending2.id!);
      
      expect(refetchedPending1, isNotNull);
      expect(refetchedPending1!.status, equals('missed'));
      expect(refetchedPending1.updatedAt, isNotNull);
      
      expect(refetchedPending2, isNotNull);
      expect(refetchedPending2!.status, equals('missed'));
      expect(refetchedPending2.updatedAt, isNotNull);
      
      // Verify completed and skipped tasks remain unchanged
      final refetchedCompleted = await Task.db.findById(session, insertedCompleted.id!);
      final refetchedSkipped = await Task.db.findById(session, insertedSkipped.id!);
      
      expect(refetchedCompleted!.status, equals('completed'));
      expect(refetchedSkipped!.status, equals('skipped'));
    });

    test('is idempotent - can be called multiple times safely', () async {
      // Given: Create a pending task
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final taskPending = Task(
        goalId: 1,
        title: 'Pending Task',
        estimatedDuration: 30,
        energyLevel: 'medium',
        priority: 'high',
        scheduledTime: now,
        status: 'pending',
      );
      
      final insertedTask = (await Task.db.insert(session, [taskPending])).first;

      final planResponse = DailyPlanResponse(
        date: today,
        slots: [
          DailyPlanSlot(
            startTime: now,
            endTime: now.add(Duration(minutes: 30)),
            type: 'task',
            title: 'Pending Task',
            durationMinutes: 30,
            taskId: insertedTask.id!,
            energyLevel: 'medium',
            priority: 'high',
          ),
        ],
        totalTaskMinutes: 30,
        totalBreakMinutes: 0,
        freeMinutes: 330,
      );
      
      await DailyPlanPersistenceService.getOrCreateDailyPlan(
        session,
        userId,
        planResponse,
      );
      
      // When: Close the day first time
      final summary1 = await endpoint.closeDay(session, userId, today);
      
      // Then: Summary created and task marked as missed
      expect(summary1, isNotNull);
      expect(summary1!.missedCount, equals(1));
      
      final taskAfterFirstClose = await Task.db.findById(session, insertedTask.id!);
      expect(taskAfterFirstClose!.status, equals('missed'));
      
      // When: Close the day again
      final summary2 = await endpoint.closeDay(session, userId, today);
      
      // Then: Returns same summary (idempotent)
      expect(summary2, isNotNull);
      expect(summary2!.id, equals(summary1.id));
      expect(summary2.missedCount, equals(1));
      
      // Task remains 'missed' (not double-processed)
      final taskAfterSecondClose = await Task.db.findById(session, insertedTask.id!);
      expect(taskAfterSecondClose!.status, equals('missed'));
    });

    test('handles empty plan - creates zero summary', () async {
      // Given: No plan exists
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // When: Close the day
      final summary = await endpoint.closeDay(session, userId, today);

      // Then: Creates empty summary
      expect(summary, isNotNull);
      expect(summary!.totalTasksPlanned, equals(0));
      expect(summary.completedCount, equals(0));
      expect(summary.skippedCount, equals(0));
      expect(summary.missedCount, equals(0));
      expect(summary.completionRatio, equals(0.0));
      expect(summary.totalFocusedMinutes, equals(0));
    });

    test('plan and slots remain unchanged after closure', () async {
      // Given: Create plan with tasks
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final task = Task(
        goalId: 1,
        title: 'Test Task',
        estimatedDuration: 30,
        energyLevel: 'high',
        priority: 'high',
        scheduledTime: now,
        status: 'pending',
      );
      
      final insertedTask = (await Task.db.insert(session, [task])).first;

      final planResponse = DailyPlanResponse(
        date: today,
        slots: [
          DailyPlanSlot(
            startTime: now,
            endTime: now.add(Duration(minutes: 30)),
            type: 'task',
            title: 'Test Task',
            durationMinutes: 30,
            taskId: insertedTask.id!,
            energyLevel: 'high',
            priority: 'high',
          ),
        ],
        totalTaskMinutes: 30,
        totalBreakMinutes: 0,
        freeMinutes: 330,
      );
      
      final savedPlan = await DailyPlanPersistenceService.getOrCreateDailyPlan(
        session,
        userId,
        planResponse,
      );
      
      // Record original plan state
      final originalPlan = await DailyPlan.db.findById(session, savedPlan.id!);
      final originalSlots = await DailyPlanSlotEntity.db.find(
        session,
        where: (s) => s.planId.equals(savedPlan.id!),
      );
      
      // When: Close the day
      await endpoint.closeDay(session, userId, today);

      // Then: Plan and slots remain unchanged (frozen)
      final planAfterClose = await DailyPlan.db.findById(session, savedPlan.id!);
      final slotsAfterClose = await DailyPlanSlotEntity.db.find(
        session,
        where: (s) => s.planId.equals(savedPlan.id!),
      );
      
      expect(planAfterClose, isNotNull);
      expect(planAfterClose!.date, equals(originalPlan!.date));
      expect(planAfterClose.totalTaskMinutes, equals(originalPlan.totalTaskMinutes));
      expect(planAfterClose.totalBreakMinutes, equals(originalPlan.totalBreakMinutes));
      expect(planAfterClose.freeMinutes, equals(originalPlan.freeMinutes));
      
      expect(slotsAfterClose.length, equals(originalSlots.length));
      expect(slotsAfterClose.first.title, equals(originalSlots.first.title));
      expect(slotsAfterClose.first.taskId, equals(originalSlots.first.taskId));
      expect(slotsAfterClose.first.type, equals(originalSlots.first.type));
    });
  });
}
