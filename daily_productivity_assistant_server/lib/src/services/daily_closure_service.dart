import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Service for handling end-of-day (EOD) closure
///
/// Responsibilities:
/// - Mark pending tasks as 'missed' at day end
/// - Compute daily summary statistics
/// - Persist DailySummary as historical record
///
/// Rules:
/// - Day ends at 9:00 PM (fixed cutoff)
/// - DailyPlan remains frozen (never mutated)
/// - Tasks are marked missed, not deleted
/// - Summary is derived data, not editable
class DailyClosureService {
  /// Fixed cutoff time for end-of-day (9 PM)
  static const eodHour = 21; // 9 PM in 24-hour format
  
  /// Closes a day by marking pending tasks as missed and creating summary
  ///
  /// This method:
  /// 1. Finds today's DailyPlan
  /// 2. Finds all tasks in the plan
  /// 3. Marks remaining 'pending' tasks as 'missed'
  /// 4. Computes summary statistics
  /// 5. Persists DailySummary
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [date] - The date to close (defaults to today)
  static Future<DailySummary?> closeDay(
    Session session,
    int userId,
    DateTime date,
  ) async {
    // Normalize to date only (remove time component)
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    // STEP 1: Check if day already closed (summary exists)
    final existingSummary = await DailySummary.db.findFirstRow(
      session,
      where: (t) => 
          t.userId.equals(userId) & 
          t.date.equals(normalizedDate),
    );
    
    if (existingSummary != null) {
      // Day already closed, return existing summary
      return existingSummary;
    }
    
    // STEP 2: Find today's DailyPlan
    final plan = await DailyPlan.db.findFirstRow(
      session,
      where: (p) => 
          p.userId.equals(userId) & 
          p.date.equals(normalizedDate),
    );
    
    // If no plan exists, create empty summary
    if (plan == null) {
      final emptySummary = DailySummary(
        userId: userId,
        date: normalizedDate,
        totalTasksPlanned: 0,
        completedCount: 0,
        skippedCount: 0,
        missedCount: 0,
        completionRatio: 0.0,
        totalFocusedMinutes: 0,
        createdAt: DateTime.now(),
      );
      
      return await DailySummary.db.insertRow(session, emptySummary);
    }
    
    // STEP 3: Find all slots in the plan
    final slots = await DailyPlanSlotEntity.db.find(
      session,
      where: (s) => s.planId.equals(plan.id!),
    );
    
    // Extract task IDs from plan slots
    final taskIdsInPlan = slots
        .where((slot) => slot.taskId != null)
        .map((slot) => slot.taskId!)
        .toSet();
    
    // If no tasks in plan, create empty summary
    if (taskIdsInPlan.isEmpty) {
      final emptySummary = DailySummary(
        userId: userId,
        date: normalizedDate,
        totalTasksPlanned: 0,
        completedCount: 0,
        skippedCount: 0,
        missedCount: 0,
        completionRatio: 0.0,
        totalFocusedMinutes: 0,
        createdAt: DateTime.now(),
      );
      
      return await DailySummary.db.insertRow(session, emptySummary);
    }
    
    // STEP 4: Fetch all tasks in the plan
    final tasks = await Task.db.find(
      session,
      where: (t) => t.id.inSet(taskIdsInPlan),
    );
    
    // STEP 5: Mark pending tasks as 'missed'
    final pendingTasks = tasks.where((t) => t.status == 'pending').toList();
    
    for (final task in pendingTasks) {
      final updatedTask = task.copyWith(
        status: 'missed',
        updatedAt: DateTime.now(),
      );
      await Task.db.updateRow(session, updatedTask);
    }
    
    // STEP 6: Compute summary statistics
    final completedTasks = tasks.where((t) => t.status == 'completed').toList();
    final skippedTasks = tasks.where((t) => t.status == 'skipped').toList();
    final missedTasks = pendingTasks; // Now marked as missed
    
    final totalPlanned = tasks.length;
    final completedCount = completedTasks.length;
    final skippedCount = skippedTasks.length;
    final missedCount = missedTasks.length;
    
    final completionRatio = totalPlanned > 0 
        ? completedCount / totalPlanned 
        : 0.0;
    
    // Calculate total focused minutes (sum of completed task durations)
    final totalFocusedMinutes = completedTasks.fold<int>(
      0,
      (sum, task) => sum + task.estimatedDuration,
    );
    
    // STEP 7: Create and persist DailySummary
    final summary = DailySummary(
      userId: userId,
      date: normalizedDate,
      totalTasksPlanned: totalPlanned,
      completedCount: completedCount,
      skippedCount: skippedCount,
      missedCount: missedCount,
      completionRatio: completionRatio,
      totalFocusedMinutes: totalFocusedMinutes,
      createdAt: DateTime.now(),
    );
    
    return await DailySummary.db.insertRow(session, summary);
  }
  
  /// Gets the DailySummary for a specific date
  ///
  /// Returns null if day has not been closed yet.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [date] - The date to retrieve summary for
  static Future<DailySummary?> getDailySummary(
    Session session,
    int userId,
    DateTime date,
  ) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    return await DailySummary.db.findFirstRow(
      session,
      where: (t) => 
          t.userId.equals(userId) & 
          t.date.equals(normalizedDate),
    );
  }
  
  /// Gets DailySummary for a date range
  ///
  /// Useful for weekly/monthly reports.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [startDate] - Start of date range (inclusive)
  /// [endDate] - End of date range (inclusive)
  static Future<List<DailySummary>> getDailySummaryRange(
    Session session,
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    
    return await DailySummary.db.find(
      session,
      where: (t) => 
          t.userId.equals(userId) & 
          t.date.between(normalizedStart, normalizedEnd),
      orderBy: (t) => t.date,
    );
  }
}
