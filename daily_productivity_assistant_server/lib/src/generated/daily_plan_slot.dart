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
import 'package:serverpod/serverpod.dart' as _i1;

abstract class DailyPlanSlot
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DailyPlanSlot._({
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.title,
    required this.durationMinutes,
    this.taskId,
    this.energyLevel,
    this.priority,
    this.status,
  });

  factory DailyPlanSlot({
    required DateTime startTime,
    required DateTime endTime,
    required String type,
    required String title,
    required int durationMinutes,
    int? taskId,
    String? energyLevel,
    String? priority,
    String? status,
  }) = _DailyPlanSlotImpl;

  factory DailyPlanSlot.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyPlanSlot(
      startTime: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      type: jsonSerialization['type'] as String,
      title: jsonSerialization['title'] as String,
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      taskId: jsonSerialization['taskId'] as int?,
      energyLevel: jsonSerialization['energyLevel'] as String?,
      priority: jsonSerialization['priority'] as String?,
      status: jsonSerialization['status'] as String?,
    );
  }

  DateTime startTime;

  DateTime endTime;

  String type;

  String title;

  int durationMinutes;

  int? taskId;

  String? energyLevel;

  String? priority;

  String? status;

  /// Returns a shallow copy of this [DailyPlanSlot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DailyPlanSlot copyWith({
    DateTime? startTime,
    DateTime? endTime,
    String? type,
    String? title,
    int? durationMinutes,
    int? taskId,
    String? energyLevel,
    String? priority,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyPlanSlot',
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
      'type': type,
      'title': title,
      'durationMinutes': durationMinutes,
      if (taskId != null) 'taskId': taskId,
      if (energyLevel != null) 'energyLevel': energyLevel,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DailyPlanSlot',
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
      'type': type,
      'title': title,
      'durationMinutes': durationMinutes,
      if (taskId != null) 'taskId': taskId,
      if (energyLevel != null) 'energyLevel': energyLevel,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyPlanSlotImpl extends DailyPlanSlot {
  _DailyPlanSlotImpl({
    required DateTime startTime,
    required DateTime endTime,
    required String type,
    required String title,
    required int durationMinutes,
    int? taskId,
    String? energyLevel,
    String? priority,
    String? status,
  }) : super._(
         startTime: startTime,
         endTime: endTime,
         type: type,
         title: title,
         durationMinutes: durationMinutes,
         taskId: taskId,
         energyLevel: energyLevel,
         priority: priority,
         status: status,
       );

  /// Returns a shallow copy of this [DailyPlanSlot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DailyPlanSlot copyWith({
    DateTime? startTime,
    DateTime? endTime,
    String? type,
    String? title,
    int? durationMinutes,
    Object? taskId = _Undefined,
    Object? energyLevel = _Undefined,
    Object? priority = _Undefined,
    Object? status = _Undefined,
  }) {
    return DailyPlanSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      taskId: taskId is int? ? taskId : this.taskId,
      energyLevel: energyLevel is String? ? energyLevel : this.energyLevel,
      priority: priority is String? ? priority : this.priority,
      status: status is String? ? status : this.status,
    );
  }
}
