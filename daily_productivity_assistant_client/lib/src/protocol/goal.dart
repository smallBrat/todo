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

/// Goal model representing a user's daily goal
abstract class Goal implements _i1.SerializableModel {
  Goal._({
    this.id,
    required this.userId,
    required this.title,
    required this.priority,
    required this.date,
    required this.status,
  });

  factory Goal({
    int? id,
    required int userId,
    required String title,
    required String priority,
    required DateTime date,
    required String status,
  }) = _GoalImpl;

  factory Goal.fromJson(Map<String, dynamic> jsonSerialization) {
    return Goal(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      title: jsonSerialization['title'] as String,
      priority: jsonSerialization['priority'] as String,
      date: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      status: jsonSerialization['status'] as String,
    );
  }

  /// Unique identifier for the goal
  int? id;

  /// Foreign key reference to the User who owns this goal
  int userId;

  /// Title or description of the goal
  String title;

  /// Priority level of the goal (low, medium, high)
  String priority;

  /// The date when the goal is set for
  DateTime date;

  /// Current status of the goal (pending, completed, skipped)
  String status;

  /// Returns a shallow copy of this [Goal]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Goal copyWith({
    int? id,
    int? userId,
    String? title,
    String? priority,
    DateTime? date,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Goal',
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'priority': priority,
      'date': date.toJson(),
      'status': status,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GoalImpl extends Goal {
  _GoalImpl({
    int? id,
    required int userId,
    required String title,
    required String priority,
    required DateTime date,
    required String status,
  }) : super._(
         id: id,
         userId: userId,
         title: title,
         priority: priority,
         date: date,
         status: status,
       );

  /// Returns a shallow copy of this [Goal]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Goal copyWith({
    Object? id = _Undefined,
    int? userId,
    String? title,
    String? priority,
    DateTime? date,
    String? status,
  }) {
    return Goal(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
