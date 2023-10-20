import 'package:kitchen_studio_10162023/dao/data_access.dart';
import 'package:kitchen_studio_10162023/dao/ingredient_data_access.dart';
import 'package:kitchen_studio_10162023/model/dock_ingredient_operation.dart';
import 'package:kitchen_studio_10162023/service/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class IngredientItemDataAccess implements DataAccess<IngredientItem> {

  IngredientDataAccess ingredientDataAccess = IngredientDataAccess.instance;


  Database? database;

  IngredientItemDataAccess._privateConstructor() {
    database = DatabaseService.instance.connectedDatabase;
  }

  static final IngredientItemDataAccess _instance =
  IngredientItemDataAccess._privateConstructor();

  static IngredientItemDataAccess get instance => _instance;

  @override
  Future<int?> create(IngredientItem t) async {
    return database?.insert(IngredientItem.tableName(), t.toJson());
  }

  @override
  Future<int?> delete(int id) async {
    return database
        ?.delete(IngredientItem.tableName(), where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<IngredientItem>?> findAll() async {
    var list = await database?.rawQuery('SELECT * FROM ${IngredientItem.tableName()}');
    return list?.map((e) {

      return IngredientItem.fromDatabase(e, null, null );
    } ).toList();
  }

  @override
  Future<IngredientItem?> getById(int id) async {
    return (await database
        ?.query(IngredientItem.tableName(), where: "id = ?", whereArgs: [id]))
        ?.map((e) => IngredientItem.fromDatabase(e, null, null ))
        .first;
  }

  @override
  Future<IngredientItem?> updateById(int id, IngredientItem t) async {
    int? count = await database?.update(
        IngredientItem.tableName(), t.toJson(),
        where: "id = ?",
        whereArgs: [id]);

    if (count != null) {
      if (count > 0) return getById(id);
    }
    return null;
  }

  @override
  Future<List<IngredientItem>?> search(String? where, {List<Object>? whereArgs}) async {
    var list = await database?.query(IngredientItem.tableName(),
        whereArgs: whereArgs, where: where);
    return list?.map((e) => IngredientItem.fromDatabase(e, null, null)).toList();
  }
}
