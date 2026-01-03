import 'package:daily_productivity_assistant_server/src/generated/protocol.dart';
import 'package:daily_productivity_assistant_server/src/logic/daily_planning_engine.dart';

/// Test script for DailyPlanningEngine
/// 
/// This script demonstrates the daily planning and scheduling system
/// by creating sample tasks and generating a realistic day plan.
void main() {
  print('\n🧪 Testing DailyPlanningEngine\n');
  print('═' * 70);

  final now = DateTime.now();

  // Create diverse test tasks
  final tasks = [
    Task(
      id: 1,
      goalId: 1,
      title: 'Check and respond to emails',
      estimatedDuration: 20,
      priority: 'low',
      energyLevel: 'low',
      status: 'pending',
      scheduledTime: null,
    ),
    Task(
      id: 2,
      goalId: 1,
      title: 'System architecture design session',
      estimatedDuration: 90,
      priority: 'high',
      energyLevel: 'high',
      status: 'pending',
      scheduledTime: null,
    ),
    Task(
      id: 3,
      goalId: 1,
      title: 'Review project documentation',
      estimatedDuration: 45,
      priority: 'medium',
      energyLevel: 'medium',
      status: 'pending',
      // Force a collision inside the generated schedule (10:30 AM)
      scheduledTime: DateTime(
        now.year,
        now.month,
        now.day,
        10,
        30,
      ),
    ),
    Task(
      id: 4,
      goalId: 1,
      title: 'Team meeting preparation',
      estimatedDuration: 30,
      priority: 'medium',
      energyLevel: 'low',
      status: 'pending',
      scheduledTime: null,
    ),
    Task(
      id: 5,
      goalId: 1,
      title: 'Code review for pull requests',
      estimatedDuration: 60,
      priority: 'high',
      energyLevel: 'medium',
      status: 'pending',
      scheduledTime: null,
    ),
  ];

  print('\n📋 Input Tasks:');
  print('─' * 70);
  for (final task in tasks) {
    final scheduled =
        task.scheduledTime != null ? '(scheduled)' : '(flexible)';
    print(
      '  [${task.priority.toUpperCase()}] ${task.title} '
      '(${task.estimatedDuration} min) $scheduled',
    );
  }

  // Generate timeline
  print('\n\n🤖 Generating Daily Timeline...\n');
  final timeline = DailyPlanningEngine.generateTimeline(
    day: now,
    tasks: tasks,
  );

  // Display timeline
  print('📅 DAILY SCHEDULE\n');
  print('─' * 70);
  
  for (int i = 0; i < timeline.length; i++) {
    final slot = timeline[i];
    
    // Color-code by type
    String typeEmoji;
    switch (slot.type) {
      case 'task':
        typeEmoji = '✅';
      case 'break':
        typeEmoji = '☕';
      case 'idle':
        typeEmoji = '⏸️ ';
      default:
        typeEmoji = '•';
    }
    
    print(
      '$typeEmoji ${slot.timeRange} | ${slot.label} '
      '(${slot.durationMinutes} min)',
    );
  }

  // Calculate statistics
  print('\n${'─' * 70}');
  print('\n📊 Schedule Statistics:');
  
  final taskSlots = timeline.where((s) => s.type == 'task');
  final totalTaskMinutes = taskSlots.fold<int>(
    0,
    (sum, slot) => sum + slot.durationMinutes,
  );
  
  final breakSlots = timeline.where((s) => s.type == 'break');
  final totalBreakMinutes = breakSlots.fold<int>(
    0,
    (sum, slot) => sum + slot.durationMinutes,
  );
  
  final idleSlots = timeline.where((s) => s.type == 'idle');
  final totalIdleMinutes = idleSlots.fold<int>(
    0,
    (sum, slot) => sum + slot.durationMinutes,
  );

  print('  • Total task time: $totalTaskMinutes minutes');
  print('  • Total break time: $totalBreakMinutes minutes');
  print('  • Free/idle time: $totalIdleMinutes minutes');
  print('  • Number of slots: ${timeline.length}');
  print('  • Day duration: 12 hours (9 AM - 9 PM)');

  print('\n${'═' * 70}');
  print('\n✅ Timeline generation completed successfully!\n');
}
