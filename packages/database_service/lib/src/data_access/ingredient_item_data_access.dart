import 'package:database_service/src/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class IngredientItemDataAccess implements DataAccess<IngredientItem> {

  IngredientDataAccess ingredientDataAccess = IngredientDataAccess.instance;


  Database? database;

  IngredientItemDataAccess._privateConstructor() {
    database = DatabasePackage.instance.connectedDatabase;
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
  Future<List<IngredientItem>?> search(String? where, {bool? distinct,
    List<String>? columns,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offse}) async {
    var list = await database?.query(IngredientItem.tableName(),
        whereArgs: whereArgs, where: where);
    return list?.map((e) => IngredientItem.fromDatabase(e, null, null)).toList();
  }
}
