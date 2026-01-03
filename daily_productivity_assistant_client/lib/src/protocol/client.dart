/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:daily_productivity_assistant_client/src/protocol/greeting.dart'
    as _i3;
import 'package:daily_productivity_assistant_client/src/protocol/next_best_task_result.dart'
    as _i4;
import 'package:daily_productivity_assistant_client/src/protocol/daily_timeline_slot.dart'
    as _i5;
import 'package:daily_productivity_assistant_client/src/protocol/daily_plan_response.dart'
    as _i6;
import 'package:daily_productivity_assistant_client/src/protocol/daily_summary.dart'
    as _i7;
import 'package:daily_productivity_assistant_client/src/protocol/task.dart'
    as _i8;
import 'protocol.dart' as _i9;

/// Development-only endpoint for seeding test data
///
/// ⚠️ WARNING: This endpoint is for testing purposes only.
/// Do NOT expose in production environments.
/// {@category Endpoint}
class EndpointDevSeed extends _i1.EndpointRef {
  EndpointDevSeed(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'devSeed';

  /// Seeds the database with fake tasks for testing the NextBestTaskEngine
  ///
  /// This method:
  /// 1. Deletes all existing tasks
  /// 2. Creates 5 diverse tasks with different characteristics
  ///
  /// Use this to quickly populate test data for development.
  _i2.Future<String> seedTasks() => caller.callServerEndpoint<String>(
    'devSeed',
    'seedTasks',
    {},
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i3.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i3.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Endpoint for planning and task recommendation functionality
/// {@category Endpoint}
class EndpointPlanning extends _i1.EndpointRef {
  EndpointPlanning(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'planning';

  /// Gets the next best task recommendation for the authenticated user
  ///
  /// Returns null if no suitable task is available, no plan exists, or user is not authenticated.
  ///
  /// The endpoint is **plan-aware**:
  /// 1. Fetches today's DailyPlan
  /// 2. Extracts eligible tasks from plan slots (started or imminent)
  /// 3. Filters pending tasks to only those in the eligible set
  /// 4. Passes filtered tasks to NextBestTaskEngine for scoring
  /// 5. Returns the recommended task with plan-aware explanation
  ///
  /// Rules:
  /// - Only considers tasks in today's plan
  /// - Time-gated: slot.startTime <= now + 15 minutes
  /// - Scoring still decides the winner (priority, urgency, energy, focus)
  /// - Plan defines candidates, engine decides the best
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user (in production, get from session.auth)
  _i2.Future<_i4.NextBestTaskResult?> getNextBestTask(int userId) =>
      caller.callServerEndpoint<_i4.NextBestTaskResult?>(
        'planning',
        'getNextBestTask',
        {'userId': userId},
      );

  /// Gets today's timeline with all tasks scheduled
  ///
  /// Returns a list of timeline slots representing the planned day
  /// with tasks, breaks, and idle time.
  _i2.Future<List<_i5.DailyTimelineSlot>> getTodayTimeline() =>
      caller.callServerEndpoint<List<_i5.DailyTimelineSlot>>(
        'planning',
        'getTodayTimeline',
        {},
      );

  /// Gets the full daily plan for a given date as a response DTO
  ///
  /// Returns a structured [DailyPlanResponse] containing:
  /// - Ordered list of time slots (tasks, breaks, idle)
  /// - Summary statistics (task minutes, break minutes, free minutes)
  ///
  /// [session] - Serverpod session for database access
  /// [date] - The date to plan for
  _i2.Future<_i6.DailyPlanResponse> getDailyPlan(DateTime date) =>
      caller.callServerEndpoint<_i6.DailyPlanResponse>(
        'planning',
        'getDailyPlan',
        {'date': date},
      );

  /// Generates and saves a daily plan for a specific date
  ///
  /// This method combines plan generation with database persistence:
  /// 1. Generates the plan using the planning engine
  /// 2. Saves the plan and all slots to the database
  /// 3. Returns the persisted DailyPlan entity
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user for whom to generate the plan
  /// [date] - The date to plan for
  _i2.Future<_i6.DailyPlanResponse> generateAndSavePlan(
    int userId,
    DateTime date,
  ) => caller.callServerEndpoint<_i6.DailyPlanResponse>(
    'planning',
    'generateAndSavePlan',
    {
      'userId': userId,
      'date': date,
    },
  );

  /// Retrieves a saved daily plan from the database
  ///
  /// Returns null if no plan exists for the specified date.
  ///
  /// Dev/demo feature: Seeds sample tasks ONLY if no tasks exist for the user.
  /// Once any task (pending OR completed) exists, seeding is permanently disabled.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [date] - The date to retrieve the plan for
  _i2.Future<_i6.DailyPlanResponse?> getSavedPlan(
    int userId,
    DateTime date,
  ) => caller.callServerEndpoint<_i6.DailyPlanResponse?>(
    'planning',
    'getSavedPlan',
    {
      'userId': userId,
      'date': date,
    },
  );

  /// Deletes a saved daily plan
  ///
  /// [session] - Serverpod session for database access
  /// [planId] - ID of the plan to delete
  _i2.Future<void> deleteSavedPlan(int planId) =>
      caller.callServerEndpoint<void>(
        'planning',
        'deleteSavedPlan',
        {'planId': planId},
      );

  /// Closes a day by marking pending tasks as missed and creating summary
  ///
  /// This endpoint:
  /// 1. Marks all remaining 'pending' tasks in today's plan as 'missed'
  /// 2. Computes daily summary statistics
  /// 3. Persists DailySummary as historical record
  /// 4. DailyPlan remains frozen (never mutated)
  ///
  /// Rules:
  /// - Day ends at 9:00 PM (fixed cutoff)
  /// - Tasks are marked missed, not deleted
  /// - Plan and slots remain unchanged
  /// - Summary is derived data, not editable
  /// - Idempotent: can be called multiple times safely
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [date] - The date to close (defaults to today if not specified)
  _i2.Future<_i7.DailySummary?> closeDay(
    int userId,
    DateTime? date,
  ) => caller.callServerEndpoint<_i7.DailySummary?>(
    'planning',
    'closeDay',
    {
      'userId': userId,
      'date': date,
    },
  );

  /// Gets the DailySummary for a specific date
  ///
  /// Returns null if day has not been closed yet.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [date] - The date to retrieve summary for
  _i2.Future<_i7.DailySummary?> getDailySummary(
    int userId,
    DateTime date,
  ) => caller.callServerEndpoint<_i7.DailySummary?>(
    'planning',
    'getDailySummary',
    {
      'userId': userId,
      'date': date,
    },
  );

  /// Gets DailySummary for a date range
  ///
  /// Useful for weekly/monthly reports.
  ///
  /// [session] - Serverpod session for database access
  /// [userId] - ID of the user
  /// [startDate] - Start of date range (inclusive)
  /// [endDate] - End of date range (inclusive)
  _i2.Future<List<_i7.DailySummary>> getDailySummaryRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) => caller.callServerEndpoint<List<_i7.DailySummary>>(
    'planning',
    'getDailySummaryRange',
    {
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
    },
  );

  /// Updates the status of a task
  ///
  /// Validates that the status is one of: "todo", "in_progress", "done"
  /// Updates the task in the database.
  ///
  /// Throws an Exception if the task is not found or status is invalid.
  ///
  /// [session] - Serverpod session for database access
  /// [taskId] - ID of the task to update
  /// [status] - New status: "todo", "in_progress", or "done"
  _i2.Future<void> updateTaskStatus(
    int taskId,
    String status,
  ) => caller.callServerEndpoint<void>(
    'planning',
    'updateTaskStatus',
    {
      'taskId': taskId,
      'status': status,
    },
  );
}

/// Endpoint for task management operations
/// {@category Endpoint}
class EndpointTask extends _i1.EndpointRef {
  EndpointTask(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'task';

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
  _i2.Future<_i8.Task> createTask(
    String title, {
    int? goalId,
    DateTime? scheduledTime,
    DateTime? deadline,
    int? estimatedDuration,
    String? priority,
    String? energyLevel,
  }) => caller.callServerEndpoint<_i8.Task>(
    'task',
    'createTask',
    {
      'title': title,
      'goalId': goalId,
      'scheduledTime': scheduledTime,
      'deadline': deadline,
      'estimatedDuration': estimatedDuration,
      'priority': priority,
      'energyLevel': energyLevel,
    },
  );

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
  _i2.Future<_i8.Task> updateTaskStatus(
    int taskId,
    String newStatus,
  ) => caller.callServerEndpoint<_i8.Task>(
    'task',
    'updateTaskStatus',
    {
      'taskId': taskId,
      'newStatus': newStatus,
    },
  );

  /// Update task core details (title, priority, duration, schedule)
  _i2.Future<_i8.Task> updateTaskDetails(
    int taskId, {
    String? title,
    String? priority,
    int? estimatedDuration,
    DateTime? scheduledTime,
  }) => caller.callServerEndpoint<_i8.Task>(
    'task',
    'updateTaskDetails',
    {
      'taskId': taskId,
      'title': title,
      'priority': priority,
      'estimatedDuration': estimatedDuration,
      'scheduledTime': scheduledTime,
    },
  );

  /// Delete a task by ID
  _i2.Future<void> deleteTask(int taskId) => caller.callServerEndpoint<void>(
    'task',
    'deleteTask',
    {'taskId': taskId},
  );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i9.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    devSeed = EndpointDevSeed(this);
    greeting = EndpointGreeting(this);
    planning = EndpointPlanning(this);
    task = EndpointTask(this);
  }

  late final EndpointDevSeed devSeed;

  late final EndpointGreeting greeting;

  late final EndpointPlanning planning;

  late final EndpointTask task;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'devSeed': devSeed,
    'greeting': greeting,
    'planning': planning,
    'task': task,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
