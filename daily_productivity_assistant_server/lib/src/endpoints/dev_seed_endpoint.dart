import 'package:serverpod/serverpod.dart';
import 'package:daily_productivity_assistant_server/src/generated/protocol.dart';

/// Development-only endpoint for seeding test data
/// 
/// ⚠️ WARNING: This endpoint is for testing purposes only.
/// Do NOT expose in production environments.
class DevSeedEndpoint extends Endpoint {
  /// Seeds the database with fake tasks for testing the NextBestTaskEngine
  ///
  /// This method:
  /// 1. Deletes all existing tasks
  /// 2. Creates 5 diverse tasks with different characteristics
  /// 
  /// Use this to quickly populate test data for development.
  Future<String> seedTasks(Session session) async {
    // Use a dedicated goalId to mark seeded demo tasks so we can safely re-seed.
    const int seedGoalId = 999001;

    // Get current local time and normalize to today's date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // STEP 1: Delete ALL existing tasks (clean slate for development)
    await Task.db.deleteWhere(
      session,
      where: (t) => t.id.notEquals(0), // Delete all
    );

    // Helper to build a DateTime for today at specific hour:minute (local time)
    DateTime at(int hour, int minute) =>
        DateTime(today.year, today.month, today.day, hour, minute);

    // STEP 2: Create demo tasks scheduled for TODAY so getDailyPlan(today) includes them.

    // Task 1: Quick win - short, low-energy task @10:00
    await Task.db.insertRow(
      session,
      Task(
        goalId: seedGoalId,
        title: 'Review emails and respond to simple queries',
        estimatedDuration: 15,
        energyLevel: 'low',
        priority: 'low',
        scheduledTime: at(10, 0),
        status: 'pending',
      ),
    );

    // Task 2: Medium complexity task @11:00
    await Task.db.insertRow(
      session,
      Task(
        goalId: seedGoalId,
        title: 'Write weekly report for team meeting',
        estimatedDuration: 30,
        energyLevel: 'medium',
        priority: 'medium',
        scheduledTime: at(11, 0),
        status: 'pending',
      ),
    );

    // Task 3: High-priority, long-duration task @13:00
    await Task.db.insertRow(
      session,
      Task(
        goalId: seedGoalId,
        title: 'Complete project proposal and budget analysis',
        estimatedDuration: 90,
        energyLevel: 'high',
        priority: 'high',
        scheduledTime: at(13, 0),
        status: 'pending',
      ),
    );

    // Task 4: Focus session @15:00 (high energy)
    await Task.db.insertRow(
      session,
      Task(
        goalId: seedGoalId,
        title: 'Deep work: refactor core module',
        estimatedDuration: 60,
        energyLevel: 'high',
        priority: 'medium',
        scheduledTime: at(15, 0),
        status: 'pending',
      ),
    );

    // Task 5: Admin wrap-up @17:00 (low energy)
    await Task.db.insertRow(
      session,
      Task(
        goalId: seedGoalId,
        title: 'Organize files and clean up desktop',
        estimatedDuration: 25,
        energyLevel: 'low',
        priority: 'low',
        scheduledTime: at(17, 0),
        status: 'pending',
      ),
    );

    return 'Seeded 5 demo tasks for today (${today.toIso8601String()})';
  }
}
