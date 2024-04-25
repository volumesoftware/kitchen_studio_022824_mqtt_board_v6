import 'package:database_service/src/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


class SystemSettingsDataAccess implements DataAccess<SystemSettings> {
  Database? database;

  SystemSettingsDataAccess._privateConstructor() {
    database = DatabasePackage.instance.connectedDatabase;
  }

  static final SystemSettingsDataAccess _instance = SystemSettingsDataAccess._privateConstructor();

  static SystemSettingsDataAccess get instance => _instance;


  @override
  Future<int?> create(SystemSettings t) async {
    return database?.insert(SystemSettings.tableName(), t.toJson());
  }

  @override
  Future<int?> delete(int id) async {
    return database?.delete(SystemSettings.tableName(), where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<SystemSettings>?> findAll() async {
    var list = await database?.rawQuery('SELECT * FROM ${SystemSettings.tableName()}');
    return list?.map((e) => SystemSettings.fromDatabase(e)).toList();
  }

  Future<SystemSettings?> getByKey(String key) async {
    return (await database
            ?.query(SystemSettings.tableName(), where: "key = ?", whereArgs: [key]))
        ?.map((e) => SystemSettings.fromDatabase(e))
        .first;
  }

  @override
  Future<SystemSettings?> getById(int id) async {
    return (await database
            ?.query(SystemSettings.tableName(), where: "id = ?", whereArgs: [id]))
        ?.map((e) => SystemSettings.fromDatabase(e))
        .first;
  }

  @override
  Future<SystemSettings?> updateById(int id, SystemSettings t) async {
    int? count = await database?.update(SystemSettings.tableName(), t.toJson(),
        where: "id = ?", whereArgs: [id]);
    if (count != null) {
      if (count > 0) return getById(id);
    }
    return null;
  }

  @override
  Future<List<SystemSettings>?> search(String? where,
      {bool? distinct,
      List<String>? columns,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offse}) async {
    var list = await database?.query(SystemSettings.tableName(),
        whereArgs: whereArgs, where: where);
    return list?.map((e) => SystemSettings.fromDatabase(e)).toList();
  }
}
