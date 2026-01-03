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

abstract class DailyTimelineSlot implements _i1.SerializableModel {
  DailyTimelineSlot._({
    required this.start,
    required this.end,
    this.taskId,
    required this.label,
    required this.type,
  });

  factory DailyTimelineSlot({
    required DateTime start,
    required DateTime end,
    int? taskId,
    required String label,
    required String type,
  }) = _DailyTimelineSlotImpl;

  factory DailyTimelineSlot.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyTimelineSlot(
      start: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['start']),
      end: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['end']),
      taskId: jsonSerialization['taskId'] as int?,
      label: jsonSerialization['label'] as String,
      type: jsonSerialization['type'] as String,
    );
  }

  DateTime start;

  DateTime end;

  int? taskId;

  String label;

  String type;

  /// Returns a shallow copy of this [DailyTimelineSlot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DailyTimelineSlot copyWith({
    DateTime? start,
    DateTime? end,
    int? taskId,
    String? label,
    String? type,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyTimelineSlot',
      'start': start.toJson(),
      'end': end.toJson(),
      if (taskId != null) 'taskId': taskId,
      'label': label,
      'type': type,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyTimelineSlotImpl extends DailyTimelineSlot {
  _DailyTimelineSlotImpl({
    required DateTime start,
    required DateTime end,
    int? taskId,
    required String label,
    required String type,
  }) : super._(
         start: start,
         end: end,
         taskId: taskId,
         label: label,
         type: type,
       );

  /// Returns a shallow copy of this [DailyTimelineSlot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DailyTimelineSlot copyWith({
    DateTime? start,
    DateTime? end,
    Object? taskId = _Undefined,
    String? label,
    String? type,
  }) {
    return DailyTimelineSlot(
      start: start ?? this.start,
      end: end ?? this.end,
      taskId: taskId is int? ? taskId : this.taskId,
      label: label ?? this.label,
      type: type ?? this.type,
    );
  }
}
