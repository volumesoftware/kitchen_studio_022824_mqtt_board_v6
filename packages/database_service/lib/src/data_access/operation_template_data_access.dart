import 'package:database_service/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class OperationTemplateDataAccess implements DataAccess<OperationTemplate> {
  Database? database;

  OperationTemplateDataAccess._privateConstructor() {
    database = DatabasePackage.instance.connectedDatabase;
  }

  static final OperationTemplateDataAccess _instance =
      OperationTemplateDataAccess._privateConstructor();

  static OperationTemplateDataAccess get instance => _instance;

  @override
  Future<int?> create(OperationTemplate t) async {
    return database?.insert(OperationTemplate.tableName(), t.toJson());
  }

  @override
  Future<int?> delete(int id) async {
    return database?.delete(OperationTemplate.tableName(),
        where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<OperationTemplate>?> findAll() async {
    var list = await database
        ?.rawQuery('SELECT * FROM ${OperationTemplate.tableName()}');
    return list?.map((e) => OperationTemplate.fromDatabase(e)).toList();
  }

  @override
  Future<OperationTemplate?> getById(int id) async {
    return (await database?.query(OperationTemplate.tableName(),
            where: "id = ?", whereArgs: [id]))
        ?.map((e) => OperationTemplate.fromDatabase(e))
        .first;
  }

  @override
  Future<List<OperationTemplate>?> search(String? where,
      {bool? distinct,
      List<String>? columns,
      List<Object?>? whereArgs,
      String? groupBy,
      String? having,
      String? orderBy,
      int? limit,
      int? offse}) async {
    var list = await database?.query(Recipe.tableName(),
        whereArgs: whereArgs, where: where);
    return list?.map((e) => OperationTemplate.fromDatabase(e)).toList();
  }

  @override
  Future<OperationTemplate?> updateById(int id, OperationTemplate t) async {
    int? count = await database?.update(
        OperationTemplate.tableName(), t.toJson(),
        where: "id = ?", whereArgs: [id]);

    if (count != null) {
      if (count > 0) return getById(id);
    }
    return null;
  }
}
