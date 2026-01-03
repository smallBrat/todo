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
import 'daily_plan_slot.dart' as _i2;
import 'package:daily_productivity_assistant_client/src/protocol/protocol.dart'
    as _i3;

abstract class DailyPlanResponse implements _i1.SerializableModel {
  DailyPlanResponse._({
    required this.date,
    required this.slots,
    required this.totalTaskMinutes,
    required this.totalBreakMinutes,
    required this.freeMinutes,
  });

  factory DailyPlanResponse({
    required DateTime date,
    required List<_i2.DailyPlanSlot> slots,
    required int totalTaskMinutes,
    required int totalBreakMinutes,
    required int freeMinutes,
  }) = _DailyPlanResponseImpl;

  factory DailyPlanResponse.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyPlanResponse(
      date: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      slots: _i3.Protocol().deserialize<List<_i2.DailyPlanSlot>>(
        jsonSerialization['slots'],
      ),
      totalTaskMinutes: jsonSerialization['totalTaskMinutes'] as int,
      totalBreakMinutes: jsonSerialization['totalBreakMinutes'] as int,
      freeMinutes: jsonSerialization['freeMinutes'] as int,
    );
  }

  DateTime date;

  List<_i2.DailyPlanSlot> slots;

  int totalTaskMinutes;

  int totalBreakMinutes;

  int freeMinutes;

  /// Returns a shallow copy of this [DailyPlanResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DailyPlanResponse copyWith({
    DateTime? date,
    List<_i2.DailyPlanSlot>? slots,
    int? totalTaskMinutes,
    int? totalBreakMinutes,
    int? freeMinutes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyPlanResponse',
      'date': date.toJson(),
      'slots': slots.toJson(valueToJson: (v) => v.toJson()),
      'totalTaskMinutes': totalTaskMinutes,
      'totalBreakMinutes': totalBreakMinutes,
      'freeMinutes': freeMinutes,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DailyPlanResponseImpl extends DailyPlanResponse {
  _DailyPlanResponseImpl({
    required DateTime date,
    required List<_i2.DailyPlanSlot> slots,
    required int totalTaskMinutes,
    required int totalBreakMinutes,
    required int freeMinutes,
  }) : super._(
         date: date,
         slots: slots,
         totalTaskMinutes: totalTaskMinutes,
         totalBreakMinutes: totalBreakMinutes,
         freeMinutes: freeMinutes,
       );

  /// Returns a shallow copy of this [DailyPlanResponse]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DailyPlanResponse copyWith({
    DateTime? date,
    List<_i2.DailyPlanSlot>? slots,
    int? totalTaskMinutes,
    int? totalBreakMinutes,
    int? freeMinutes,
  }) {
    return DailyPlanResponse(
      date: date ?? this.date,
      slots: slots ?? this.slots.map((e0) => e0.copyWith()).toList(),
      totalTaskMinutes: totalTaskMinutes ?? this.totalTaskMinutes,
      totalBreakMinutes: totalBreakMinutes ?? this.totalBreakMinutes,
      freeMinutes: freeMinutes ?? this.freeMinutes,
    );
  }
}
