import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:daily_productivity_assistant_server/src/generated/protocol.dart';
import 'package:daily_productivity_assistant_server/src/generated/endpoints.dart';
import 'package:daily_productivity_assistant_server/src/endpoints/planning_endpoint.dart';
import 'package:daily_productivity_assistant_server/src/services/daily_plan_persistence_service.dart';

/// Integration test for plan-aware getNextBestTask endpoint
///
/// This test verifies that getNextBestTask:
/// 1. Only considers tasks in today's saved plan
/// 2. Filters by time-gate (slot.startTime <= now + 15 min)
/// 3. Returns null when no plan exists
/// 4. Returns null when no eligible tasks exist
/// 5. Calls NextBestTaskEngine for scoring among eligible tasks
void main() {
  group('Plan-aware getNextBestTask', () {
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
    });

    tearDown(() async {
      await session.close();
    });

    tearDownAll(() async {
      await pod.shutdown(exitProcess: false);
    });

    test('returns null when no plan exists', () async {
      // Given: No plan saved for today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Clean up any existing plan
      final existingPlan = await DailyPlanPersistenceService.getDailyPlan(
        session,
        userId,
        today,
      );
      if (existingPlan != null) {
        await DailyPlanPersistenceService.deleteDailyPlan(session, existingPlan.id!);
      }

      // When: Get next best task
      final result = await endpoint.getNextBestTask(session, userId);

      // Then: Returns null (no plan = no candidates)
      expect(result, isNull);
    });

    test('returns null when no task slots are eligible (all in future)', () async {
      // Given: A plan with tasks starting later (> 15 min from now)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Create tasks
      final taskA = Task(
        goalId: 1,
        title: 'Future Task A',
        estimatedDuration: 30,
        energyLevel: 'high',
        priority: 'high',
        scheduledTime: now.add(Duration(hours: 2)),
        status: 'pending',
      );
      
      final insertedA = (await Task.db.insert(session, [taskA])).first;

      // Create plan with future slots
      final futureStartA = now.add(Duration(hours: 2));
      
      final planResponse = DailyPlanResponse(
        date: today,
        slots: [
          DailyPlanSlot(
            startTime: futureStartA,
            endTime: futureStartA.add(Duration(minutes: 30)),
            type: 'task',
            title: 'Future Task A',
            durationMinutes: 30,
            taskId: insertedA.id!,
            energyLevel: 'high',
            priority: 'high',
          ),
        ],
        totalTaskMinutes: 30,
        totalBreakMinutes: 0,
        freeMinutes: 330,
      );
      
      // Save plan
      final savedPlan = await DailyPlanPersistenceService.getOrCreateDailyPlan(
        session,
        userId,
        planResponse,
      );
      
      // When: Get next best task
      final result = await endpoint.getNextBestTask(session, userId);

      // Then: Returns null (all slots in future, none eligible)
      expect(result, isNull);
      
      // Cleanup
      await DailyPlanPersistenceService.deleteDailyPlan(session, savedPlan.id!);
      await Task.db.deleteWhere(session, where: (t) => t.id.equals(insertedA.id!));
    });

    test('returns task when slot is eligible (started or imminent)', () async {
      // Given: A plan with a task starting now
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Create task
      final taskA = Task(
        goalId: 1,
        title: 'Current Task',
        estimatedDuration: 30,
        energyLevel: 'medium',
        priority: 'high',
        scheduledTime: now.subtract(Duration(minutes: 5)), // Started 5 min ago
        status: 'pending',
      );
      
      final insertedA = (await Task.db.insert(session, [taskA])).first;

      // Create plan
      final startA = now.subtract(Duration(minutes: 5));
      
      final planResponse = DailyPlanResponse(
        date: today,
        slots: [
          DailyPlanSlot(
            startTime: startA,
            endTime: startA.add(Duration(minutes: 30)),
            type: 'task',
            title: 'Current Task',
            durationMinutes: 30,
            taskId: insertedA.id!,
            energyLevel: 'medium',
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
      
      // When: Get next best task
      final result = await endpoint.getNextBestTask(session, userId);

      // Then: Returns Task A (eligible and high priority)
      expect(result, isNotNull);
      expect(result!.taskId, equals(insertedA.id!));
      expect(result.explanation, contains('scheduled in your plan'));
      
      // Cleanup
      await DailyPlanPersistenceService.deleteDailyPlan(session, savedPlan.id!);
      await Task.db.deleteWhere(session, where: (t) => t.id.equals(insertedA.id!));
    });

    test('ignores tasks not in plan (even if pending)', () async {
      // Given: Tasks in DB, but plan only includes some of them
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Create tasks
      final taskInPlan = Task(
        goalId: 1,
        title: 'Planned Task',
        estimatedDuration: 30,
        energyLevel: 'medium',
        priority: 'medium',
        scheduledTime: now.subtract(Duration(minutes: 5)),
        status: 'pending',
      );
      
      final taskNotInPlan = Task(
        goalId: 1,
        title: 'Unplanned Task',
        estimatedDuration: 30,
        energyLevel: 'high',
        priority: 'high', // Higher priority!
        scheduledTime: now.subtract(Duration(minutes: 10)),
        status: 'pending',
      );
      
      final insertedInPlan = (await Task.db.insert(session, [taskInPlan])).first;
      final insertedNotInPlan = (await Task.db.insert(session, [taskNotInPlan])).first;

      // Create plan - only includes taskInPlan
      final startTime = now.subtract(Duration(minutes: 5));
      
      final planResponse = DailyPlanResponse(
        date: today,
        slots: [
          DailyPlanSlot(
            startTime: startTime,
            endTime: startTime.add(Duration(minutes: 30)),
            type: 'task',
            title: 'Planned Task',
            durationMinutes: 30,
            taskId: insertedInPlan.id!,
            energyLevel: 'medium',
            priority: 'medium',
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
      
      // When: Get next best task
      final result = await endpoint.getNextBestTask(session, userId);

      // Then: Returns taskInPlan (even though taskNotInPlan has higher priority)
      // because taskNotInPlan is not in the plan
      expect(result, isNotNull);
      expect(result!.taskId, equals(insertedInPlan.id!));
      expect(result.taskId, isNot(equals(insertedNotInPlan.id!)));
      
      // Cleanup
      await DailyPlanPersistenceService.deleteDailyPlan(session, savedPlan.id!);
      await Task.db.deleteWhere(session, where: (t) => t.id.equals(insertedInPlan.id!));
      await Task.db.deleteWhere(session, where: (t) => t.id.equals(insertedNotInPlan.id!));
    });

    test('respects 15-minute grace window', () async {
      // Given: Task starting at now + 10 min (within grace)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final taskImminent = Task(
        goalId: 1,
        title: 'Imminent Task',
        estimatedDuration: 30,
        energyLevel: 'medium',
        priority: 'high',
        scheduledTime: now.add(Duration(minutes: 10)), // In 10 min
        status: 'pending',
      );
      
      final insertedTask = (await Task.db.insert(session, [taskImminent])).first;

      // Create plan
      final startTime = now.add(Duration(minutes: 10));
      
      final planResponse = DailyPlanResponse(
        date: today,
        slots: [
          DailyPlanSlot(
            startTime: startTime,
            endTime: startTime.add(Duration(minutes: 30)),
            type: 'task',
            title: 'Imminent Task',
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
      
      final savedPlan = await DailyPlanPersistenceService.getOrCreateDailyPlan(
        session,
        userId,
        planResponse,
      );
      
      // When: Get next best task
      final result = await endpoint.getNextBestTask(session, userId);

      // Then: Returns task (within 15-min grace window)
      expect(result, isNotNull);
      expect(result!.taskId, equals(insertedTask.id!));
      
      // Cleanup
      await DailyPlanPersistenceService.deleteDailyPlan(session, savedPlan.id!);
      await Task.db.deleteWhere(session, where: (t) => t.id.equals(insertedTask.id!));
    });
  });
}
