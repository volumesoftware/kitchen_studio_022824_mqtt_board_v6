import 'package:database_service/src/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class RecipeDataAccess implements DataAccess<Recipe> {
  Database? database;

  RecipeDataAccess._privateConstructor() {
    database = DatabasePackage.instance.connectedDatabase;
  }

  static final RecipeDataAccess _instance =
      RecipeDataAccess._privateConstructor();

  static RecipeDataAccess get instance => _instance;

  @override
  Future<int?> create(Recipe t) async {
    return database?.insert(Recipe.tableName(), t.toJson());
  }

  @override
  Future<int?> delete(int id) async {
    database?.delete(BaseOperation.tableName(), where: "recipe_id = ?", whereArgs: [id]);
    return database
        ?.delete(Recipe.tableName(), where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<Recipe>?> findAll() async {
    var list = await database?.rawQuery('SELECT * FROM ${Recipe.tableName()}');
    return list?.map((e) => Recipe.fromDatabase(e)).toList();
  }

  @override
  Future<Recipe?> getById(int id) async {
    return (await database
            ?.query(Recipe.tableName(), where: "id = ?", whereArgs: [id]))
        ?.map((e) => Recipe.fromDatabase(e))
        .first;
  }

  @override
  Future<Recipe?> updateById(int id, Recipe t) async {
    int? count = await database?.update(
        Recipe.tableName(), t.toJson(),
        where: "id = ?",
        whereArgs: [id]);

    if (count != null) {
      if (count > 0) return getById(id);
    }
    return null;
  }

  @override
  Future<List<Recipe>?> search(String? where, {List<Object>? whereArgs}) async {
    var list = await database?.query(Recipe.tableName(),
        whereArgs: whereArgs, where: where);
    return list?.map((e) => Recipe.fromDatabase(e)).toList();
  }
}
