import 'package:kitchen_studio_10162023/dao/data_access.dart';
import 'package:kitchen_studio_10162023/model/task.dart';
import 'package:kitchen_studio_10162023/service/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TaskDataAccess implements DataAccess<Task> {
  Database? database;

  TaskDataAccess._privateConstructor() {
    database = DatabaseService.instance.connectedDatabase;
  }

  static final TaskDataAccess _instance =
      TaskDataAccess._privateConstructor();

  static TaskDataAccess get instance => _instance;

  @override
  Future<int?> create(Task t) async {
    return database?.insert(Task.tableName(), t.toJson());
  }

  @override
  Future<int?> delete(int id) async {
    return database
        ?.delete(Task.tableName(), where: "id = ?", whereArgs: [id]);
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
    int? count = await database?.update(
        Task.tableName(), t.toJson(),
        where: "id = ?",
        whereArgs: [id]);

    if (count != null) {
      if (count > 0) return getById(id);
    }
    return null;
  }

  @override
  Future<List<Task>?> search(String? where, {List<Object>? whereArgs}) async {
    var list = await database?.query(Task.tableName(),
        whereArgs: whereArgs, where: where);
    return list?.map((e) => Task.fromDatabase(e)).toList();
  }
}
