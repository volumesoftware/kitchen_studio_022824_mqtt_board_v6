import 'package:database_service/src/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DeviceDataAccess implements DataAccess<DeviceStats> {
  Database? database;

  DeviceDataAccess._privateConstructor() {
    database = DatabasePackage.instance.connectedDatabase;
  }

  static final DeviceDataAccess _instance =
      DeviceDataAccess._privateConstructor();

  static DeviceDataAccess get instance => _instance;

  @override
  Future<int?> create(DeviceStats t) async {
    return database?.insert(DeviceStats.tableName(), t.toJson());
  }

  @override
  Future<int?> delete(int id) async {
    return database
        ?.delete(DeviceStats.tableName(), where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<DeviceStats>?> findAll() async {
    var list =
        await database?.rawQuery('SELECT * FROM ${DeviceStats.tableName()}');
    return list?.map((e) => DeviceStats.fromDatabase(e)).toList();
  }

  @override
  Future<DeviceStats?> getById(int id) async {
    return (await database
            ?.query(DeviceStats.tableName(), where: "id = ?", whereArgs: [id]))
        ?.map((e) => DeviceStats.fromDatabase(e))
        .first;
  }

  @override
  Future<DeviceStats?> updateById(int id, DeviceStats t) async {
    int? count = await database?.update(DeviceStats.tableName(), t.toJson(),
        where: "id = ?", whereArgs: [id]);

    if (count != null) {
      if (count > 0) return getById(id);
    }
    return null;
  }

  @override
  Future<List<DeviceStats>?> search(String? where,
      {List<Object>? whereArgs}) async {
    var list = await database?.query(DeviceStats.tableName(),
        whereArgs: whereArgs, where: where);
    return list?.map((e) => DeviceStats.fromDatabase(e)).toList();
  }
}
