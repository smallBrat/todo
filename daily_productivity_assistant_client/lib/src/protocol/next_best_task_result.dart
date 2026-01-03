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
import 'package:daily_productivity_assistant_client/src/protocol/protocol.dart'
    as _i2;

abstract class NextBestTaskResult implements _i1.SerializableModel {
  NextBestTaskResult._({
    required this.taskId,
    required this.totalScore,
    required this.scoreBreakdown,
    required this.explanation,
  });

  factory NextBestTaskResult({
    required int taskId,
    required double totalScore,
    required Map<String, double> scoreBreakdown,
    required String explanation,
  }) = _NextBestTaskResultImpl;

  factory NextBestTaskResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return NextBestTaskResult(
      taskId: jsonSerialization['taskId'] as int,
      totalScore: (jsonSerialization['totalScore'] as num).toDouble(),
      scoreBreakdown: _i2.Protocol().deserialize<Map<String, double>>(
        jsonSerialization['scoreBreakdown'],
      ),
      explanation: jsonSerialization['explanation'] as String,
    );
  }

  int taskId;

  double totalScore;

  Map<String, double> scoreBreakdown;

  String explanation;

  /// Returns a shallow copy of this [NextBestTaskResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NextBestTaskResult copyWith({
    int? taskId,
    double? totalScore,
    Map<String, double>? scoreBreakdown,
    String? explanation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NextBestTaskResult',
      'taskId': taskId,
      'totalScore': totalScore,
      'scoreBreakdown': scoreBreakdown.toJson(),
      'explanation': explanation,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _NextBestTaskResultImpl extends NextBestTaskResult {
  _NextBestTaskResultImpl({
    required int taskId,
    required double totalScore,
    required Map<String, double> scoreBreakdown,
    required String explanation,
  }) : super._(
         taskId: taskId,
         totalScore: totalScore,
         scoreBreakdown: scoreBreakdown,
         explanation: explanation,
       );

  /// Returns a shallow copy of this [NextBestTaskResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NextBestTaskResult copyWith({
    int? taskId,
    double? totalScore,
    Map<String, double>? scoreBreakdown,
    String? explanation,
  }) {
    return NextBestTaskResult(
      taskId: taskId ?? this.taskId,
      totalScore: totalScore ?? this.totalScore,
      scoreBreakdown:
          scoreBreakdown ??
          this.scoreBreakdown.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
      explanation: explanation ?? this.explanation,
    );
  }
}
