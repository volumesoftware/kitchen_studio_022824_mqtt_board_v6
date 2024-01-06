import 'package:database_service/src/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract interface class TaskChangedListener {
  void onChange();
}

class TaskDataAccess implements DataAccess<Task> {
  Database? database;

  List<TaskChangedListener> _listeners = [];

  TaskDataAccess._privateConstructor() {
    database = DatabasePackage.instance.connectedDatabase;
  }

  static final TaskDataAccess _instance = TaskDataAccess._privateConstructor();

  static TaskDataAccess get instance => _instance;

  void listen(TaskChangedListener listener) {
    _listeners.add(listener);
  }

  void removeListener(TaskChangedListener listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    _listeners.forEach((element) {
      element.onChange();
    });
  }

  @override
  Future<int?> create(Task t) async {
    Future.delayed(const Duration(seconds: 2), () {
      notifyListeners();
    });
    return database?.insert(Task.tableName(), t.toJson());
  }

  @override
  Future<int?> delete(int id) async {
    Future.delayed(const Duration(seconds: 2), () {
      notifyListeners();
    });
    return database?.delete(Task.tableName(), where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<Task>?> findAll() async {
    var list = await database?.rawQuery('SELECT * FROM ${Task.tableName()}');
    return list?.map((e) => Task.fromDatabase(e)).toList();
  }

  @override
  Future<Task?> getById(int id) async {
    return (await database
            ?.query(Task.tableName(), where: "id = ?", whereArgs: [id]))
        ?.map((e) => Task.fromDatabase(e))
        .first;
  }

  @override
  Future<Task?> updateById(int id, Task t) async {
    int? count = await database?.update(Task.tableName(), t.toJson(),
        where: "id = ?", whereArgs: [id]);

    if (count != null) {
      notifyListeners();
      if (count > 0) return getById(id);
    }
    return null;
  }

  @override
  Future<List<Task>?> search(String? where,
      {bool? distinct,
      List<String>? columns,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offse}) async {
    var list = await database?.query(Task.tableName(),
        whereArgs: whereArgs, where: where);
    return list?.map((e) => Task.fromDatabase(e)).toList();
  }
}
