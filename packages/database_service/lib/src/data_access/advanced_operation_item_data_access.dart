import 'package:database_service/src/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AdvancedOperationItemDataAccess implements DataAccess<AdvancedOperationItem> {

  IngredientDataAccess ingredientDataAccess = IngredientDataAccess.instance;


  Database? database;

  AdvancedOperationItemDataAccess._privateConstructor() {
    database = DatabasePackage.instance.connectedDatabase;
  }

  static final AdvancedOperationItemDataAccess _instance =
  AdvancedOperationItemDataAccess._privateConstructor();

  static AdvancedOperationItemDataAccess get instance => _instance;

  @override
  Future<int?> create(AdvancedOperationItem t) async {
    return database?.insert(AdvancedOperationItem.tableName(), t.toJson());
  }

  @override
  Future<int?> delete(int id) async {
    return database
        ?.delete(AdvancedOperationItem.tableName(), where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<AdvancedOperationItem>?> findAll() async {
    var list = await database?.rawQuery('SELECT * FROM ${AdvancedOperationItem.tableName()}');
    return list?.map((e) {
      return AdvancedOperationItem.fromDatabase(e );
    } ).toList();
  }

  @override
  Future<AdvancedOperationItem?> getById(int id) async {
    return (await database
        ?.query(AdvancedOperationItem.tableName(), where: "id = ?", whereArgs: [id]))
        ?.map((e) => AdvancedOperationItem.fromDatabase(e ))
        .first;
  }

  @override
  Future<AdvancedOperationItem?> updateById(int id, AdvancedOperationItem t) async {
    int? count = await database?.update(
        AdvancedOperationItem.tableName(), t.toJson(),
        where: "id = ?",
        whereArgs: [id]);

    if (count != null) {
      if (count > 0) return getById(id);
    }
    return null;
  }

  @override
  Future<List<AdvancedOperationItem>?> search(String? where, {List<Object>? whereArgs}) async {
    var list = await database?.query(AdvancedOperationItem.tableName(),
        whereArgs: whereArgs, where: where);
    return list?.map((e) => AdvancedOperationItem.fromDatabase(e)).toList();
  }
}
