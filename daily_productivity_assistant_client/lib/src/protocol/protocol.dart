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
import 'daily_plan_response.dart' as _i2;
import 'daily_plan_slot.dart' as _i3;
import 'daily_summary.dart' as _i4;
import 'daily_timeline_slot.dart' as _i5;
import 'goal.dart' as _i6;
import 'greeting.dart' as _i7;
import 'next_best_task_result.dart' as _i8;
import 'task.dart' as _i9;
import 'package:daily_productivity_assistant_client/src/protocol/daily_timeline_slot.dart'
    as _i10;
import 'package:daily_productivity_assistant_client/src/protocol/daily_summary.dart'
    as _i11;
export 'daily_plan_response.dart';
export 'daily_plan_slot.dart';
export 'daily_summary.dart';
export 'daily_timeline_slot.dart';
export 'goal.dart';
export 'greeting.dart';
export 'next_best_task_result.dart';
export 'task.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.DailyPlanResponse) {
      return _i2.DailyPlanResponse.fromJson(data) as T;
    }
    if (t == _i3.DailyPlanSlot) {
      return _i3.DailyPlanSlot.fromJson(data) as T;
    }
    if (t == _i4.DailySummary) {
      return _i4.DailySummary.fromJson(data) as T;
    }
    if (t == _i5.DailyTimelineSlot) {
      return _i5.DailyTimelineSlot.fromJson(data) as T;
    }
    if (t == _i6.Goal) {
      return _i6.Goal.fromJson(data) as T;
    }
    if (t == _i7.Greeting) {
      return _i7.Greeting.fromJson(data) as T;
    }
    if (t == _i8.NextBestTaskResult) {
      return _i8.NextBestTaskResult.fromJson(data) as T;
    }
    if (t == _i9.Task) {
      return _i9.Task.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.DailyPlanResponse?>()) {
      return (data != null ? _i2.DailyPlanResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.DailyPlanSlot?>()) {
      return (data != null ? _i3.DailyPlanSlot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.DailySummary?>()) {
      return (data != null ? _i4.DailySummary.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.DailyTimelineSlot?>()) {
      return (data != null ? _i5.DailyTimelineSlot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Goal?>()) {
      return (data != null ? _i6.Goal.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Greeting?>()) {
      return (data != null ? _i7.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.NextBestTaskResult?>()) {
      return (data != null ? _i8.NextBestTaskResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Task?>()) {
      return (data != null ? _i9.Task.fromJson(data) : null) as T;
    }
    if (t == List<_i3.DailyPlanSlot>) {
      return (data as List)
              .map((e) => deserialize<_i3.DailyPlanSlot>(e))
              .toList()
          as T;
    }
    if (t == Map<String, double>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<double>(v)),
          )
          as T;
    }
    if (t == List<_i10.DailyTimelineSlot>) {
      return (data as List)
              .map((e) => deserialize<_i10.DailyTimelineSlot>(e))
              .toList()
          as T;
    }
    if (t == List<_i11.DailySummary>) {
      return (data as List)
              .map((e) => deserialize<_i11.DailySummary>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.DailyPlanResponse => 'DailyPlanResponse',
      _i3.DailyPlanSlot => 'DailyPlanSlot',
      _i4.DailySummary => 'DailySummary',
      _i5.DailyTimelineSlot => 'DailyTimelineSlot',
      _i6.Goal => 'Goal',
      _i7.Greeting => 'Greeting',
      _i8.NextBestTaskResult => 'NextBestTaskResult',
      _i9.Task => 'Task',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'daily_productivity_assistant.',
        '',
      );
    }

    switch (data) {
      case _i2.DailyPlanResponse():
        return 'DailyPlanResponse';
      case _i3.DailyPlanSlot():
        return 'DailyPlanSlot';
      case _i4.DailySummary():
        return 'DailySummary';
      case _i5.DailyTimelineSlot():
        return 'DailyTimelineSlot';
      case _i6.Goal():
        return 'Goal';
      case _i7.Greeting():
        return 'Greeting';
      case _i8.NextBestTaskResult():
        return 'NextBestTaskResult';
      case _i9.Task():
        return 'Task';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'DailyPlanResponse') {
      return deserialize<_i2.DailyPlanResponse>(data['data']);
    }
    if (dataClassName == 'DailyPlanSlot') {
      return deserialize<_i3.DailyPlanSlot>(data['data']);
    }
    if (dataClassName == 'DailySummary') {
      return deserialize<_i4.DailySummary>(data['data']);
    }
    if (dataClassName == 'DailyTimelineSlot') {
      return deserialize<_i5.DailyTimelineSlot>(data['data']);
    }
    if (dataClassName == 'Goal') {
      return deserialize<_i6.Goal>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i7.Greeting>(data['data']);
    }
    if (dataClassName == 'NextBestTaskResult') {
      return deserialize<_i8.NextBestTaskResult>(data['data']);
    }
    if (dataClassName == 'Task') {
      return deserialize<_i9.Task>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
