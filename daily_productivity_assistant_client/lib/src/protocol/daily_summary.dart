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

/// Daily summary model for tracking daily productivity metrics
/// Generated at end-of-day (9 PM cutoff) as a frozen historical record
abstract class DailySummary implements _i1.SerializableModel {
  DailySummary._({
    this.id,
    required this.userId,
    required this.date,
    required this.totalTasksPlanned,
    required this.completedCount,
    required this.skippedCount,
    required this.missedCount,
    required this.completionRatio,
    required this.totalFocusedMinutes,
    required this.createdAt,
  });

  factory DailySummary({
    int? id,
    required int userId,
    required DateTime date,
    required int totalTasksPlanned,
    required int completedCount,
    required int skippedCount,
    required int missedCount,
    required double completionRatio,
    required int totalFocusedMinutes,
    required DateTime createdAt,
  }) = _DailySummaryImpl;

  factory DailySummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailySummary(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      date: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      totalTasksPlanned: jsonSerialization['totalTasksPlanned'] as int,
      completedCount: jsonSerialization['completedCount'] as int,
      skippedCount: jsonSerialization['skippedCount'] as int,
      missedCount: jsonSerialization['missedCount'] as int,
      completionRatio: (jsonSerialization['completionRatio'] as num).toDouble(),
      totalFocusedMinutes: jsonSerialization['totalFocusedMinutes'] as int,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// Unique identifier for the daily summary
  int? id;

  /// User ID this summary belongs to
  int userId;

  /// The date for this summary
  DateTime date;

  /// Total number of tasks planned in the DailyPlan
  int totalTasksPlanned;

  /// Number of tasks completed
  int completedCount;

  /// Number of tasks explicitly skipped by user
  int skippedCount;

  /// Number of tasks that were pending at day end (ran out of time)
  int missedCount;

  /// Completion ratio (completedCount / totalTasksPlanned)
  double completionRatio;

  /// Total focused minutes (sum of completed task durations)
  int totalFocusedMinutes;

  /// Timestamp when this summary was created (EOD closure time)
  DateTime createdAt;

  /// Returns a shallow copy of this [DailySummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DailySummary copyWith({
    int? id,
    int? userId,
    DateTime? date,
    int? totalTasksPlanned,
    int? completedCount,
    int? skippedCount,
    int? missedCount,
    double? completionRatio,
    int? totalFocusedMinutes,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailySummary',
      if (id != null) 'id': id,
      'userId': userId,
      'date': date.toJson(),
      'totalTasksPlanned': totalTasksPlanned,
      'completedCount': completedCount,
      'skippedCount': skippedCount,
      'missedCount': missedCount,
      'completionRatio': completionRatio,
      'totalFocusedMinutes': totalFocusedMinutes,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailySummaryImpl extends DailySummary {
  _DailySummaryImpl({
    int? id,
    required int userId,
    required DateTime date,
    required int totalTasksPlanned,
    required int completedCount,
    required int skippedCount,
    required int missedCount,
    required double completionRatio,
    required int totalFocusedMinutes,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         date: date,
         totalTasksPlanned: totalTasksPlanned,
         completedCount: completedCount,
         skippedCount: skippedCount,
         missedCount: missedCount,
         completionRatio: completionRatio,
         totalFocusedMinutes: totalFocusedMinutes,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DailySummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DailySummary copyWith({
    Object? id = _Undefined,
    int? userId,
    DateTime? date,
    int? totalTasksPlanned,
    int? completedCount,
    int? skippedCount,
    int? missedCount,
    double? completionRatio,
    int? totalFocusedMinutes,
    DateTime? createdAt,
  }) {
    return DailySummary(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      totalTasksPlanned: totalTasksPlanned ?? this.totalTasksPlanned,
      completedCount: completedCount ?? this.completedCount,
      skippedCount: skippedCount ?? this.skippedCount,
      missedCount: missedCount ?? this.missedCount,
      completionRatio: completionRatio ?? this.completionRatio,
      totalFocusedMinutes: totalFocusedMinutes ?? this.totalFocusedMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
