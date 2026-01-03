import 'package:daily_productivity_assistant_server/src/generated/protocol.dart';
import 'package:daily_productivity_assistant_server/src/logic/next_best_task_engine.dart';

void main() {
  print('\n🧪 Testing NextBestTaskEngine (Pure Logic Test)');
  print('═' * 60);

  final now = DateTime.now();

  // Create mock tasks (NO DATABASE)
  final tasks = [
    Task(
      id: 1,
      goalId: 1,
      title: 'Check emails',
      estimatedDuration: 15,
      energyLevel: 'low',
      priority: 'low',
      scheduledTime: null,
      status: 'pending',
    ),
    Task(
      id: 2,
      goalId: 1,
      title: 'Update documentation',
      estimatedDuration: 45,
      energyLevel: 'medium',
      priority: 'medium',
      scheduledTime: now,
      status: 'pending',
    ),
    Task(
      id: 3,
      goalId: 1,
      title: 'Design system architecture',
      estimatedDuration: 90,
      energyLevel: 'high',
      priority: 'high',
      scheduledTime: null,
      status: 'pending',
    ),
  ];

  // Run recommendation engine
  final result = NextBestTaskEngine.getNextBestTask(
    now: now,
    pendingTasks: tasks,
    isUserBehindSchedule: false,
    userEnergyLevel: 'medium',
  );

  print('\n🤖 Recommendation Result');
  print('═' * 60);

  if (result == null) {
    print('❌ No task selected');
    return;
  }

  final selectedTask =
      tasks.firstWhere((t) => t.id == result.taskId);

  print('Task:       ${selectedTask.title}');
  print('Priority:   ${selectedTask.priority}');
  print('Energy:     ${selectedTask.energyLevel}');
  print('\n📈 Total Score: ${result.totalScore.toStringAsFixed(2)}');
  print('\n📊 Score Breakdown:');
  result.scoreBreakdown.forEach((factor, score) {
    print('   • $factor: ${score.toStringAsFixed(2)}');
  });
  print('\n💡 Explanation: ${result.explanation}');

  print('\n✅ Logic test completed successfully\n');
}
