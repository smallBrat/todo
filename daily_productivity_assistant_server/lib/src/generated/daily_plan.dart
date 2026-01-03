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

/// DailyPlan represents a user's plan for a specific day
abstract class DailyPlan
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  DailyPlan._({
    this.id,
    required this.userId,
    required this.date,
    required this.totalTaskMinutes,
    required this.totalBreakMinutes,
    required this.freeMinutes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DailyPlan({
    int? id,
    required int userId,
    required DateTime date,
    required int totalTaskMinutes,
    required int totalBreakMinutes,
    required int freeMinutes,
    DateTime? createdAt,
  }) = _DailyPlanImpl;

  factory DailyPlan.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyPlan(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      date: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      totalTaskMinutes: jsonSerialization['totalTaskMinutes'] as int,
      totalBreakMinutes: jsonSerialization['totalBreakMinutes'] as int,
      freeMinutes: jsonSerialization['freeMinutes'] as int,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = DailyPlanTable();

  static const db = DailyPlanRepository._();

  @override
  int? id;

  /// Foreign key reference to the user who owns this plan
  int userId;

  /// The date this plan is for
  DateTime date;

  /// Total minutes allocated to tasks
  int totalTaskMinutes;

  /// Total minutes allocated to breaks
  int totalBreakMinutes;

  /// Total minutes of idle/free time
  int freeMinutes;

  /// Timestamp when this plan was created
  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [DailyPlan]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DailyPlan copyWith({
    int? id,
    int? userId,
    DateTime? date,
    int? totalTaskMinutes,
    int? totalBreakMinutes,
    int? freeMinutes,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyPlan',
      if (id != null) 'id': id,
      'userId': userId,
      'date': date.toJson(),
      'totalTaskMinutes': totalTaskMinutes,
      'totalBreakMinutes': totalBreakMinutes,
      'freeMinutes': freeMinutes,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DailyPlanInclude include() {
    return DailyPlanInclude._();
  }

  static DailyPlanIncludeList includeList({
    _i1.WhereExpressionBuilder<DailyPlanTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyPlanTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyPlanTable>? orderByList,
    DailyPlanInclude? include,
  }) {
    return DailyPlanIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyPlan.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DailyPlan.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyPlanImpl extends DailyPlan {
  _DailyPlanImpl({
    int? id,
    required int userId,
    required DateTime date,
    required int totalTaskMinutes,
    required int totalBreakMinutes,
    required int freeMinutes,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         date: date,
         totalTaskMinutes: totalTaskMinutes,
         totalBreakMinutes: totalBreakMinutes,
         freeMinutes: freeMinutes,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DailyPlan]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DailyPlan copyWith({
    Object? id = _Undefined,
    int? userId,
    DateTime? date,
    int? totalTaskMinutes,
    int? totalBreakMinutes,
    int? freeMinutes,
    DateTime? createdAt,
  }) {
    return DailyPlan(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      totalTaskMinutes: totalTaskMinutes ?? this.totalTaskMinutes,
      totalBreakMinutes: totalBreakMinutes ?? this.totalBreakMinutes,
      freeMinutes: freeMinutes ?? this.freeMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DailyPlanUpdateTable extends _i1.UpdateTable<DailyPlanTable> {
  DailyPlanUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> date(DateTime value) => _i1.ColumnValue(
    table.date,
    value,
  );

  _i1.ColumnValue<int, int> totalTaskMinutes(int value) => _i1.ColumnValue(
    table.totalTaskMinutes,
    value,
  );

  _i1.ColumnValue<int, int> totalBreakMinutes(int value) => _i1.ColumnValue(
    table.totalBreakMinutes,
    value,
  );

  _i1.ColumnValue<int, int> freeMinutes(int value) => _i1.ColumnValue(
    table.freeMinutes,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class DailyPlanTable extends _i1.Table<int?> {
  DailyPlanTable({super.tableRelation}) : super(tableName: 'daily_plan') {
    updateTable = DailyPlanUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    date = _i1.ColumnDateTime(
      'date',
      this,
    );
    totalTaskMinutes = _i1.ColumnInt(
      'totalTaskMinutes',
      this,
    );
    totalBreakMinutes = _i1.ColumnInt(
      'totalBreakMinutes',
      this,
    );
    freeMinutes = _i1.ColumnInt(
      'freeMinutes',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final DailyPlanUpdateTable updateTable;

  /// Foreign key reference to the user who owns this plan
  late final _i1.ColumnInt userId;

  /// The date this plan is for
  late final _i1.ColumnDateTime date;

  /// Total minutes allocated to tasks
  late final _i1.ColumnInt totalTaskMinutes;

  /// Total minutes allocated to breaks
  late final _i1.ColumnInt totalBreakMinutes;

  /// Total minutes of idle/free time
  late final _i1.ColumnInt freeMinutes;

  /// Timestamp when this plan was created
  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    date,
    totalTaskMinutes,
    totalBreakMinutes,
    freeMinutes,
    createdAt,
  ];
}

class DailyPlanInclude extends _i1.IncludeObject {
  DailyPlanInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => DailyPlan.t;
}

class DailyPlanIncludeList extends _i1.IncludeList {
  DailyPlanIncludeList._({
    _i1.WhereExpressionBuilder<DailyPlanTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DailyPlan.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DailyPlan.t;
}

class DailyPlanRepository {
  const DailyPlanRepository._();

  /// Returns a list of [DailyPlan]s matching the given query parameters.
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
  Future<List<DailyPlan>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyPlanTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyPlanTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyPlanTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<DailyPlan>(
      where: where?.call(DailyPlan.t),
      orderBy: orderBy?.call(DailyPlan.t),
      orderByList: orderByList?.call(DailyPlan.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [DailyPlan] matching the given query parameters.
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
  Future<DailyPlan?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyPlanTable>? where,
    int? offset,
    _i1.OrderByBuilder<DailyPlanTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyPlanTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<DailyPlan>(
      where: where?.call(DailyPlan.t),
      orderBy: orderBy?.call(DailyPlan.t),
      orderByList: orderByList?.call(DailyPlan.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [DailyPlan] by its [id] or null if no such row exists.
  Future<DailyPlan?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<DailyPlan>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [DailyPlan]s in the list and returns the inserted rows.
  ///
  /// The returned [DailyPlan]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DailyPlan>> insert(
    _i1.Session session,
    List<DailyPlan> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DailyPlan>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DailyPlan] and returns the inserted row.
  ///
  /// The returned [DailyPlan] will have its `id` field set.
  Future<DailyPlan> insertRow(
    _i1.Session session,
    DailyPlan row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DailyPlan>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DailyPlan]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DailyPlan>> update(
    _i1.Session session,
    List<DailyPlan> rows, {
    _i1.ColumnSelections<DailyPlanTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DailyPlan>(
      rows,
      columns: columns?.call(DailyPlan.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyPlan]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DailyPlan> updateRow(
    _i1.Session session,
    DailyPlan row, {
    _i1.ColumnSelections<DailyPlanTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DailyPlan>(
      row,
      columns: columns?.call(DailyPlan.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyPlan] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DailyPlan?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<DailyPlanUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DailyPlan>(
      id,
      columnValues: columnValues(DailyPlan.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DailyPlan]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DailyPlan>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<DailyPlanUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<DailyPlanTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyPlanTable>? orderBy,
    _i1.OrderByListBuilder<DailyPlanTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DailyPlan>(
      columnValues: columnValues(DailyPlan.t.updateTable),
      where: where(DailyPlan.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyPlan.t),
      orderByList: orderByList?.call(DailyPlan.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DailyPlan]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DailyPlan>> delete(
    _i1.Session session,
    List<DailyPlan> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DailyPlan>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DailyPlan].
  Future<DailyPlan> deleteRow(
    _i1.Session session,
    DailyPlan row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DailyPlan>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DailyPlan>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DailyPlanTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DailyPlan>(
      where: where(DailyPlan.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyPlanTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DailyPlan>(
      where: where?.call(DailyPlan.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
