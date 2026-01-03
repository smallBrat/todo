import 'package:test/test.dart';
import 'package:daily_productivity_assistant_server/src/generated/protocol.dart';
import 'package:daily_productivity_assistant_server/src/logic/next_best_task_engine.dart';

void main() {
  group('NextBestTaskEngine', () {
    test('selects overdue, energy-matched pending task (Task B)', () {
      // Given
      final now = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        10,
        30,
      );
      const userEnergy = 'low';
      const isUserBehindSchedule = true;

      // Tasks
      final taskA = Task(
        id: 1,
        goalId: 1,
        title: 'Task A',
        estimatedDuration: 30,
        energyLevel: 'high',
        priority: 'high',
        scheduledTime: null,
        status: 'pending',
      );

      final taskB = Task(
        id: 2,
        goalId: 1,
        title: 'Task B',
        estimatedDuration: 30,
        energyLevel: 'low',
        priority: 'medium',
        scheduledTime: DateTime(now.year, now.month, now.day, 10, 0), // overdue
        status: 'pending',
      );

      final taskC = Task(
        id: 3,
        goalId: 1,
        title: 'Task C',
        estimatedDuration: 30,
        energyLevel: 'medium',
        priority: 'low',
        scheduledTime: null,
        status: 'completed',
      );

      final taskD = Task(
        id: 4,
        goalId: 1,
        title: 'Task D',
        estimatedDuration: 30,
        energyLevel: 'low',
        priority: 'low',
        scheduledTime: null,
        status: 'skipped',
      );

      final tasks = [taskA, taskB, taskC, taskD];

      // When
      final result = NextBestTaskEngine.getNextBestTask(
        now: now,
        pendingTasks: tasks,
        isUserBehindSchedule: isUserBehindSchedule,
        userEnergyLevel: userEnergy,
      );

      // Then
      expect(result, isNotNull, reason: 'Engine should return a task');
      expect(result!.taskId, taskB.id);

      // Explanation should mention scheduling/urgency and energy matching
      final explanation = result.explanation.toLowerCase();
      expect(
        explanation.contains('approaching deadline') || explanation.contains('scheduled'),
        isTrue,
        reason: 'Explanation should mention overdue/scheduled/urgency',
      );
      expect(
        explanation.contains('energy fit') || explanation.contains('urgency'),
        isTrue,
        reason: 'Explanation should mention energy match or urgency',
      );
    });
  });
}
