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

/// DailyPlanSlotEntity represents a time slot in a daily plan
abstract class DailyPlanSlotEntity
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  DailyPlanSlotEntity._({
    this.id,
    required this.planId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.type,
    required this.title,
    this.taskId,
    this.energyLevel,
    this.priority,
  });

  factory DailyPlanSlotEntity({
    int? id,
    required int planId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    required String type,
    required String title,
    int? taskId,
    String? energyLevel,
    String? priority,
  }) = _DailyPlanSlotEntityImpl;

  factory DailyPlanSlotEntity.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyPlanSlotEntity(
      id: jsonSerialization['id'] as int?,
      planId: jsonSerialization['planId'] as int,
      startTime: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startTime'],
      ),
      endTime: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endTime']),
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      type: jsonSerialization['type'] as String,
      title: jsonSerialization['title'] as String,
      taskId: jsonSerialization['taskId'] as int?,
      energyLevel: jsonSerialization['energyLevel'] as String?,
      priority: jsonSerialization['priority'] as String?,
    );
  }

  static final t = DailyPlanSlotEntityTable();

  static const db = DailyPlanSlotEntityRepository._();

  @override
  int? id;

  /// Foreign key reference to the parent DailyPlan
  int planId;

  /// Start time of this slot
  DateTime startTime;

  /// End time of this slot
  DateTime endTime;

  /// Duration of this slot in minutes
  int durationMinutes;

  /// Type of slot: "task", "break", or "idle"
  String type;

  /// Title or label for this slot
  String title;

  /// Optional task ID if this slot is for a specific task
  int? taskId;

  /// Optional energy level required (low, medium, high)
  String? energyLevel;

  /// Optional priority level
  String? priority;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [DailyPlanSlotEntity]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DailyPlanSlotEntity copyWith({
    int? id,
    int? planId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? type,
    String? title,
    int? taskId,
    String? energyLevel,
    String? priority,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyPlanSlotEntity',
      if (id != null) 'id': id,
      'planId': planId,
      'startTime': startTime.toJson(),
      'endTime': endTime.toJson(),
      'durationMinutes': durationMinutes,
      'type': type,
      'title': title,
      if (taskId != null) 'taskId': taskId,
      if (energyLevel != null) 'energyLevel': energyLevel,
      if (priority != null) 'priority': priority,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DailyPlanSlotEntityInclude include() {
    return DailyPlanSlotEntityInclude._();
  }

  static DailyPlanSlotEntityIncludeList includeList({
    _i1.WhereExpressionBuilder<DailyPlanSlotEntityTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyPlanSlotEntityTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyPlanSlotEntityTable>? orderByList,
    DailyPlanSlotEntityInclude? include,
  }) {
    return DailyPlanSlotEntityIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyPlanSlotEntity.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DailyPlanSlotEntity.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyPlanSlotEntityImpl extends DailyPlanSlotEntity {
  _DailyPlanSlotEntityImpl({
    int? id,
    required int planId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    required String type,
    required String title,
    int? taskId,
    String? energyLevel,
    String? priority,
  }) : super._(
         id: id,
         planId: planId,
         startTime: startTime,
         endTime: endTime,
         durationMinutes: durationMinutes,
         type: type,
         title: title,
         taskId: taskId,
         energyLevel: energyLevel,
         priority: priority,
       );

  /// Returns a shallow copy of this [DailyPlanSlotEntity]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DailyPlanSlotEntity copyWith({
    Object? id = _Undefined,
    int? planId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? type,
    String? title,
    Object? taskId = _Undefined,
    Object? energyLevel = _Undefined,
    Object? priority = _Undefined,
  }) {
    return DailyPlanSlotEntity(
      id: id is int? ? id : this.id,
      planId: planId ?? this.planId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      type: type ?? this.type,
      title: title ?? this.title,
      taskId: taskId is int? ? taskId : this.taskId,
      energyLevel: energyLevel is String? ? energyLevel : this.energyLevel,
      priority: priority is String? ? priority : this.priority,
    );
  }
}

class DailyPlanSlotEntityUpdateTable
    extends _i1.UpdateTable<DailyPlanSlotEntityTable> {
  DailyPlanSlotEntityUpdateTable(super.table);

  _i1.ColumnValue<int, int> planId(int value) => _i1.ColumnValue(
    table.planId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> startTime(DateTime value) =>
      _i1.ColumnValue(
        table.startTime,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> endTime(DateTime value) =>
      _i1.ColumnValue(
        table.endTime,
        value,
      );

  _i1.ColumnValue<int, int> durationMinutes(int value) => _i1.ColumnValue(
    table.durationMinutes,
    value,
  );

  _i1.ColumnValue<String, String> type(String value) => _i1.ColumnValue(
    table.type,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<int, int> taskId(int? value) => _i1.ColumnValue(
    table.taskId,
    value,
  );

  _i1.ColumnValue<String, String> energyLevel(String? value) => _i1.ColumnValue(
    table.energyLevel,
    value,
  );

  _i1.ColumnValue<String, String> priority(String? value) => _i1.ColumnValue(
    table.priority,
    value,
  );
}

class DailyPlanSlotEntityTable extends _i1.Table<int?> {
  DailyPlanSlotEntityTable({super.tableRelation})
    : super(tableName: 'daily_plan_slot') {
    updateTable = DailyPlanSlotEntityUpdateTable(this);
    planId = _i1.ColumnInt(
      'planId',
      this,
    );
    startTime = _i1.ColumnDateTime(
      'startTime',
      this,
    );
    endTime = _i1.ColumnDateTime(
      'endTime',
      this,
    );
    durationMinutes = _i1.ColumnInt(
      'durationMinutes',
      this,
    );
    type = _i1.ColumnString(
      'type',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    taskId = _i1.ColumnInt(
      'taskId',
      this,
    );
    energyLevel = _i1.ColumnString(
      'energyLevel',
      this,
    );
    priority = _i1.ColumnString(
      'priority',
      this,
    );
  }

  late final DailyPlanSlotEntityUpdateTable updateTable;

  /// Foreign key reference to the parent DailyPlan
  late final _i1.ColumnInt planId;

  /// Start time of this slot
  late final _i1.ColumnDateTime startTime;

  /// End time of this slot
  late final _i1.ColumnDateTime endTime;

  /// Duration of this slot in minutes
  late final _i1.ColumnInt durationMinutes;

  /// Type of slot: "task", "break", or "idle"
  late final _i1.ColumnString type;

  /// Title or label for this slot
  late final _i1.ColumnString title;

  /// Optional task ID if this slot is for a specific task
  late final _i1.ColumnInt taskId;

  /// Optional energy level required (low, medium, high)
  late final _i1.ColumnString energyLevel;

  /// Optional priority level
  late final _i1.ColumnString priority;

  @override
  List<_i1.Column> get columns => [
    id,
    planId,
    startTime,
    endTime,
    durationMinutes,
    type,
    title,
    taskId,
    energyLevel,
    priority,
  ];
}

class DailyPlanSlotEntityInclude extends _i1.IncludeObject {
  DailyPlanSlotEntityInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => DailyPlanSlotEntity.t;
}

class DailyPlanSlotEntityIncludeList extends _i1.IncludeList {
  DailyPlanSlotEntityIncludeList._({
    _i1.WhereExpressionBuilder<DailyPlanSlotEntityTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DailyPlanSlotEntity.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DailyPlanSlotEntity.t;
}

class DailyPlanSlotEntityRepository {
  const DailyPlanSlotEntityRepository._();

  /// Returns a list of [DailyPlanSlotEntity]s matching the given query parameters.
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
  Future<List<DailyPlanSlotEntity>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyPlanSlotEntityTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyPlanSlotEntityTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyPlanSlotEntityTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<DailyPlanSlotEntity>(
      where: where?.call(DailyPlanSlotEntity.t),
      orderBy: orderBy?.call(DailyPlanSlotEntity.t),
      orderByList: orderByList?.call(DailyPlanSlotEntity.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [DailyPlanSlotEntity] matching the given query parameters.
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
  Future<DailyPlanSlotEntity?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyPlanSlotEntityTable>? where,
    int? offset,
    _i1.OrderByBuilder<DailyPlanSlotEntityTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyPlanSlotEntityTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<DailyPlanSlotEntity>(
      where: where?.call(DailyPlanSlotEntity.t),
      orderBy: orderBy?.call(DailyPlanSlotEntity.t),
      orderByList: orderByList?.call(DailyPlanSlotEntity.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [DailyPlanSlotEntity] by its [id] or null if no such row exists.
  Future<DailyPlanSlotEntity?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<DailyPlanSlotEntity>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [DailyPlanSlotEntity]s in the list and returns the inserted rows.
  ///
  /// The returned [DailyPlanSlotEntity]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DailyPlanSlotEntity>> insert(
    _i1.Session session,
    List<DailyPlanSlotEntity> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DailyPlanSlotEntity>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DailyPlanSlotEntity] and returns the inserted row.
  ///
  /// The returned [DailyPlanSlotEntity] will have its `id` field set.
  Future<DailyPlanSlotEntity> insertRow(
    _i1.Session session,
    DailyPlanSlotEntity row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DailyPlanSlotEntity>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DailyPlanSlotEntity]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DailyPlanSlotEntity>> update(
    _i1.Session session,
    List<DailyPlanSlotEntity> rows, {
    _i1.ColumnSelections<DailyPlanSlotEntityTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DailyPlanSlotEntity>(
      rows,
      columns: columns?.call(DailyPlanSlotEntity.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyPlanSlotEntity]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DailyPlanSlotEntity> updateRow(
    _i1.Session session,
    DailyPlanSlotEntity row, {
    _i1.ColumnSelections<DailyPlanSlotEntityTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DailyPlanSlotEntity>(
      row,
      columns: columns?.call(DailyPlanSlotEntity.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyPlanSlotEntity] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DailyPlanSlotEntity?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<DailyPlanSlotEntityUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DailyPlanSlotEntity>(
      id,
      columnValues: columnValues(DailyPlanSlotEntity.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DailyPlanSlotEntity]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DailyPlanSlotEntity>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<DailyPlanSlotEntityUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<DailyPlanSlotEntityTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyPlanSlotEntityTable>? orderBy,
    _i1.OrderByListBuilder<DailyPlanSlotEntityTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DailyPlanSlotEntity>(
      columnValues: columnValues(DailyPlanSlotEntity.t.updateTable),
      where: where(DailyPlanSlotEntity.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyPlanSlotEntity.t),
      orderByList: orderByList?.call(DailyPlanSlotEntity.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DailyPlanSlotEntity]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DailyPlanSlotEntity>> delete(
    _i1.Session session,
    List<DailyPlanSlotEntity> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DailyPlanSlotEntity>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DailyPlanSlotEntity].
  Future<DailyPlanSlotEntity> deleteRow(
    _i1.Session session,
    DailyPlanSlotEntity row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DailyPlanSlotEntity>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DailyPlanSlotEntity>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DailyPlanSlotEntityTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DailyPlanSlotEntity>(
      where: where(DailyPlanSlotEntity.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyPlanSlotEntityTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DailyPlanSlotEntity>(
      where: where?.call(DailyPlanSlotEntity.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
