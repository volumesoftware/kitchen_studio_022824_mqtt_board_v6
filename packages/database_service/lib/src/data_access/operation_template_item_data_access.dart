import 'package:database_service/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class OperationTemplateItemDataAccess
    implements DataAccess<OperationTemplateItem> {
  Database? database;

  OperationTemplateItemDataAccess._privateConstructor() {
    database = DatabasePackage.instance.connectedDatabase;
  }

  static final OperationTemplateItemDataAccess _instance =
      OperationTemplateItemDataAccess._privateConstructor();

  static OperationTemplateItemDataAccess get instance => _instance;

  @override
  Future<int?> create(OperationTemplateItem t) async {
    return database?.insert(OperationTemplateItem.tableName(), t.toJson());
  }

  @override
  Future<int?> delete(int id) async {
    return database?.delete(OperationTemplateItem.tableName(),
        where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<OperationTemplateItem>?> findAll() async {
    var list = await database
        ?.rawQuery('SELECT * FROM ${OperationTemplateItem.tableName()}');
    return list?.map((e) => OperationTemplateItem.fromDatabase(e)).toList();
  }

  @override
  Future<OperationTemplateItem?> getById(int id) async {
    return (await database?.query(OperationTemplateItem.tableName(),
            where: "id = ?", whereArgs: [id]))
        ?.map((e) => OperationTemplateItem.fromDatabase(e))
        .first;
  }

  @override
  Future<List<OperationTemplateItem>?> search(String? where,
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
    return list?.map((e) => OperationTemplateItem.fromDatabase(e)).toList();
  }

  @override
  Future<OperationTemplateItem?> updateById(
      int id, OperationTemplateItem t) async {
    int? count = await database?.update(
        OperationTemplateItem.tableName(), t.toJson(),
        where: "id = ?", whereArgs: [id]);

    if (count != null) {
      if (count > 0) return getById(id);
    }
    return null;
  }
}
