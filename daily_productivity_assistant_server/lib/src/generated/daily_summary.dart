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

/// Daily summary model for tracking daily productivity metrics
/// Generated at end-of-day (9 PM cutoff) as a frozen historical record
abstract class DailySummary
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = DailySummaryTable();

  static const db = DailySummaryRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static DailySummaryInclude include() {
    return DailySummaryInclude._();
  }

  static DailySummaryIncludeList includeList({
    _i1.WhereExpressionBuilder<DailySummaryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailySummaryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailySummaryTable>? orderByList,
    DailySummaryInclude? include,
  }) {
    return DailySummaryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailySummary.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DailySummary.t),
      include: include,
    );
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

class DailySummaryUpdateTable extends _i1.UpdateTable<DailySummaryTable> {
  DailySummaryUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> date(DateTime value) => _i1.ColumnValue(
    table.date,
    value,
  );

  _i1.ColumnValue<int, int> totalTasksPlanned(int value) => _i1.ColumnValue(
    table.totalTasksPlanned,
    value,
  );

  _i1.ColumnValue<int, int> completedCount(int value) => _i1.ColumnValue(
    table.completedCount,
    value,
  );

  _i1.ColumnValue<int, int> skippedCount(int value) => _i1.ColumnValue(
    table.skippedCount,
    value,
  );

  _i1.ColumnValue<int, int> missedCount(int value) => _i1.ColumnValue(
    table.missedCount,
    value,
  );

  _i1.ColumnValue<double, double> completionRatio(double value) =>
      _i1.ColumnValue(
        table.completionRatio,
        value,
      );

  _i1.ColumnValue<int, int> totalFocusedMinutes(int value) => _i1.ColumnValue(
    table.totalFocusedMinutes,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class DailySummaryTable extends _i1.Table<int?> {
  DailySummaryTable({super.tableRelation}) : super(tableName: 'daily_summary') {
    updateTable = DailySummaryUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    date = _i1.ColumnDateTime(
      'date',
      this,
    );
    totalTasksPlanned = _i1.ColumnInt(
      'totalTasksPlanned',
      this,
    );
    completedCount = _i1.ColumnInt(
      'completedCount',
      this,
    );
    skippedCount = _i1.ColumnInt(
      'skippedCount',
      this,
    );
    missedCount = _i1.ColumnInt(
      'missedCount',
      this,
    );
    completionRatio = _i1.ColumnDouble(
      'completionRatio',
      this,
    );
    totalFocusedMinutes = _i1.ColumnInt(
      'totalFocusedMinutes',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final DailySummaryUpdateTable updateTable;

  /// User ID this summary belongs to
  late final _i1.ColumnInt userId;

  /// The date for this summary
  late final _i1.ColumnDateTime date;

  /// Total number of tasks planned in the DailyPlan
  late final _i1.ColumnInt totalTasksPlanned;

  /// Number of tasks completed
  late final _i1.ColumnInt completedCount;

  /// Number of tasks explicitly skipped by user
  late final _i1.ColumnInt skippedCount;

  /// Number of tasks that were pending at day end (ran out of time)
  late final _i1.ColumnInt missedCount;

  /// Completion ratio (completedCount / totalTasksPlanned)
  late final _i1.ColumnDouble completionRatio;

  /// Total focused minutes (sum of completed task durations)
  late final _i1.ColumnInt totalFocusedMinutes;

  /// Timestamp when this summary was created (EOD closure time)
  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    date,
    totalTasksPlanned,
    completedCount,
    skippedCount,
    missedCount,
    completionRatio,
    totalFocusedMinutes,
    createdAt,
  ];
}

class DailySummaryInclude extends _i1.IncludeObject {
  DailySummaryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => DailySummary.t;
}

class DailySummaryIncludeList extends _i1.IncludeList {
  DailySummaryIncludeList._({
    _i1.WhereExpressionBuilder<DailySummaryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DailySummary.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DailySummary.t;
}

class DailySummaryRepository {
  const DailySummaryRepository._();

  /// Returns a list of [DailySummary]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<DailySummary>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailySummaryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailySummaryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailySummaryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<DailySummary>(
      where: where?.call(DailySummary.t),
      orderBy: orderBy?.call(DailySummary.t),
      orderByList: orderByList?.call(DailySummary.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [DailySummary] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<DailySummary?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailySummaryTable>? where,
    int? offset,
    _i1.OrderByBuilder<DailySummaryTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailySummaryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<DailySummary>(
      where: where?.call(DailySummary.t),
      orderBy: orderBy?.call(DailySummary.t),
      orderByList: orderByList?.call(DailySummary.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [DailySummary] by its [id] or null if no such row exists.
  Future<DailySummary?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<DailySummary>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [DailySummary]s in the list and returns the inserted rows.
  ///
  /// The returned [DailySummary]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DailySummary>> insert(
    _i1.Session session,
    List<DailySummary> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DailySummary>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DailySummary] and returns the inserted row.
  ///
  /// The returned [DailySummary] will have its `id` field set.
  Future<DailySummary> insertRow(
    _i1.Session session,
    DailySummary row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DailySummary>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DailySummary]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DailySummary>> update(
    _i1.Session session,
    List<DailySummary> rows, {
    _i1.ColumnSelections<DailySummaryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DailySummary>(
      rows,
      columns: columns?.call(DailySummary.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailySummary]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DailySummary> updateRow(
    _i1.Session session,
    DailySummary row, {
    _i1.ColumnSelections<DailySummaryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DailySummary>(
      row,
      columns: columns?.call(DailySummary.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailySummary] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DailySummary?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<DailySummaryUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DailySummary>(
      id,
      columnValues: columnValues(DailySummary.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DailySummary]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DailySummary>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<DailySummaryUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<DailySummaryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailySummaryTable>? orderBy,
    _i1.OrderByListBuilder<DailySummaryTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DailySummary>(
      columnValues: columnValues(DailySummary.t.updateTable),
      where: where(DailySummary.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailySummary.t),
      orderByList: orderByList?.call(DailySummary.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DailySummary]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DailySummary>> delete(
    _i1.Session session,
    List<DailySummary> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DailySummary>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DailySummary].
  Future<DailySummary> deleteRow(
    _i1.Session session,
    DailySummary row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DailySummary>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DailySummary>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DailySummaryTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DailySummary>(
      where: where(DailySummary.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailySummaryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DailySummary>(
      where: where?.call(DailySummary.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
