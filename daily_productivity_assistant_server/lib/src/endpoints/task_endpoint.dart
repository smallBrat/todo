import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Endpoint for task management operations
class TaskEndpoint extends Endpoint {
  /// Create a new task with validation
  ///
  /// [title] - Task title (required, non-empty)
  /// [goalId] - Goal/User ID to associate with task (defaults to 1 for demo)
  /// [scheduledTime] - When task is scheduled (ALWAYS LOCAL TIME, never UTC)
  /// [deadline] - When task should be completed by (optional)
  /// [estimatedDuration] - Duration in minutes (defaults to 30)
  /// [priority] - Priority level: 'low', 'medium', 'high' (defaults to 'medium')
  /// [energyLevel] - Energy required: 'low', 'medium', 'high' (defaults to 'medium')
  ///
  /// Returns the created Task object with assigned ID
  ///
  /// NOTE: scheduledTime is expected as local time. If received as UTC (isUtc=true),
  /// it will be converted back to local time to match user intent.
  Future<Task> createTask(
    Session session,
    String title, {
    int? goalId,
    DateTime? scheduledTime,
    DateTime? deadline,
    int? estimatedDuration,
    String? priority,
    String? energyLevel,
  }) async {
    // Validate title
    if (title.trim().isEmpty) {
      throw Exception('Task title cannot be empty.');
    }

    // FIX: If scheduledTime is marked as UTC, convert it back to local time
    // This handles the case where the client sends local time but it gets
    // marked as UTC during serialization
    DateTime? localScheduledTime = scheduledTime;
    if (scheduledTime != null && scheduledTime.isUtc) {
      localScheduledTime = scheduledTime.toLocal();
      session.log('⚠️  Received UTC-marked time, converting to local: $scheduledTime → $localScheduledTime');
    }

    // Create new task with defaults
    final task = Task(
      goalId: goalId ?? 1, // Default to demo user
      title: title.trim(),
      status: 'pending', // Always start as pending
      estimatedDuration: estimatedDuration ?? 30,
      priority: priority ?? 'medium',
      energyLevel: energyLevel ?? 'medium',
      scheduledTime: localScheduledTime, // Always store as local time
      deadline: deadline, // Can be null
      updatedAt: DateTime.now(),
    );

    // 🔍 DEBUG: Log the received and stored times
    if (scheduledTime != null) {
      final isUtc = scheduledTime.isUtc;
      session.log('⏰ createTask: Received scheduledTime=$scheduledTime (isUtc=$isUtc) → Storing=$localScheduledTime');
    }

    // Insert into database (ID auto-assigned by PostgreSQL)
    final createdTask = await Task.db.insertRow(session, task);

    // 🔍 DEBUG LOG: Verify creation
    session.log('✅ Created task ${createdTask.id}: "${createdTask.title}" scheduled=${createdTask.scheduledTime}');

    return createdTask;
  }

  /// Update task status with validation and atomic persistence
  ///
  /// [taskId] - ID of the task to update
  /// [newStatus] - Target status: "pending", "in_progress", "completed", or "skipped"
  ///
  /// Returns the updated Task object
  ///
  /// Throws Exception if:
  /// - newStatus is invalid
  /// - task not found
  Future<Task> updateTaskStatus(
    Session session,
    int taskId,
    String newStatus,
  ) async {
    // Validate status input
    if (!['pending', 'in_progress', 'completed', 'skipped'].contains(newStatus)) {
      throw Exception(
        'Invalid status: $newStatus. Must be "pending", "in_progress", "completed", or "skipped".',
      );
    }

    // Fetch task by ID
    final task = await Task.db.findById(session, taskId);
    if (task == null) {
      throw Exception('Task with ID $taskId not found.');
    }

    // Update task properties
    task.status = newStatus;
    task.updatedAt = DateTime.now();

    // Manage completedAt timestamp based on status
    if (newStatus == 'completed') {
      task.completedAt = DateTime.now();
    } else {
      // Clear completedAt if moving out of completed state
      task.completedAt = null;
    }

    // Persist to database
    await Task.db.updateRow(session, task);

    // 🔍 DEBUG LOG: Verify persistence
    session.log('✅ Updated task ${task.id}: status=${task.status}, completedAt=${task.completedAt}');

    return task;
  }

  /// Update task core details (title, priority, duration, schedule)
  Future<Task> updateTaskDetails(
    Session session,
    int taskId, {
    String? title,
    String? priority,
    int? estimatedDuration,
    DateTime? scheduledTime,
  }) async {
    final task = await Task.db.findById(session, taskId);
    if (task == null) {
      throw Exception('Task with ID $taskId not found.');
    }

    if (title != null && title.trim().isEmpty) {
      throw Exception('Task title cannot be empty.');
    }

    if (priority != null && !['low', 'medium', 'high'].contains(priority)) {
      throw Exception('Invalid priority: $priority.');
    }

    if (estimatedDuration != null && estimatedDuration <= 0) {
      throw Exception('Duration must be positive.');
    }

    task
      ..title = title?.trim() ?? task.title
      ..priority = priority ?? task.priority
      ..estimatedDuration = estimatedDuration ?? task.estimatedDuration
      ..scheduledTime = scheduledTime ?? task.scheduledTime
      ..updatedAt = DateTime.now();

    await Task.db.updateRow(session, task);
    session.log('✅ Updated task ${task.id}: title="${task.title}", priority=${task.priority}, duration=${task.estimatedDuration}, scheduled=${task.scheduledTime}');

    return task;
  }

  /// Delete a task by ID
  Future<void> deleteTask(Session session, int taskId) async {
    final task = await Task.db.findById(session, taskId);
    if (task == null) {
      throw Exception('Task with ID $taskId not found.');
    }

    await Task.db.deleteRow(session, task);
    session.log('🗑️ Deleted task $taskId');
  }
}
