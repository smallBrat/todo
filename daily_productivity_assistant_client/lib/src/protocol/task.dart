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

abstract class Task implements _i1.SerializableModel {
  Task._({
    this.id,
    required this.goalId,
    required this.title,
    required this.estimatedDuration,
    required this.energyLevel,
    required this.priority,
    this.scheduledTime,
    this.deadline,
    required this.status,
    this.completedAt,
    this.updatedAt,
  });

  factory Task({
    int? id,
    required int goalId,
    required String title,
    required int estimatedDuration,
    required String energyLevel,
    required String priority,
    DateTime? scheduledTime,
    DateTime? deadline,
    required String status,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) = _TaskImpl;

  factory Task.fromJson(Map<String, dynamic> jsonSerialization) {
    return Task(
      id: jsonSerialization['id'] as int?,
      goalId: jsonSerialization['goalId'] as int,
      title: jsonSerialization['title'] as String,
      estimatedDuration: jsonSerialization['estimatedDuration'] as int,
      energyLevel: jsonSerialization['energyLevel'] as String,
      priority: jsonSerialization['priority'] as String,
      scheduledTime: jsonSerialization['scheduledTime'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['scheduledTime'],
            ),
      deadline: jsonSerialization['deadline'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deadline']),
      status: jsonSerialization['status'] as String,
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int goalId;

  String title;

  int estimatedDuration;

  String energyLevel;

  String priority;

  DateTime? scheduledTime;

  /// Task deadline: when the task should be completed by
  /// - null means no deadline
  /// - DateTime value indicates deadline for the task
  DateTime? deadline;

  /// Task status: 'pending', 'completed', 'skipped', 'missed'
  /// - pending: not yet done
  /// - completed: finished by user
  /// - skipped: explicitly skipped by user
  /// - missed: was pending at day end (9 PM cutoff)
  String status;

  DateTime? completedAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Task copyWith({
    int? id,
    int? goalId,
    String? title,
    int? estimatedDuration,
    String? energyLevel,
    String? priority,
    DateTime? scheduledTime,
    DateTime? deadline,
    String? status,
    DateTime? completedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Task',
      if (id != null) 'id': id,
      'goalId': goalId,
      'title': title,
      'estimatedDuration': estimatedDuration,
      'energyLevel': energyLevel,
      'priority': priority,
      if (scheduledTime != null) 'scheduledTime': scheduledTime?.toJson(),
      if (deadline != null) 'deadline': deadline?.toJson(),
      'status': status,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaskImpl extends Task {
  _TaskImpl({
    int? id,
    required int goalId,
    required String title,
    required int estimatedDuration,
    required String energyLevel,
    required String priority,
    DateTime? scheduledTime,
    DateTime? deadline,
    required String status,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         goalId: goalId,
         title: title,
         estimatedDuration: estimatedDuration,
         energyLevel: energyLevel,
         priority: priority,
         scheduledTime: scheduledTime,
         deadline: deadline,
         status: status,
         completedAt: completedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Task copyWith({
    Object? id = _Undefined,
    int? goalId,
    String? title,
    int? estimatedDuration,
    String? energyLevel,
    String? priority,
    Object? scheduledTime = _Undefined,
    Object? deadline = _Undefined,
    String? status,
    Object? completedAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return Task(
      id: id is int? ? id : this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      energyLevel: energyLevel ?? this.energyLevel,
      priority: priority ?? this.priority,
      scheduledTime: scheduledTime is DateTime?
          ? scheduledTime
          : this.scheduledTime,
      deadline: deadline is DateTime? ? deadline : this.deadline,
      status: status ?? this.status,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
