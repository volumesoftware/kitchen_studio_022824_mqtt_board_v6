import 'package:kitchen_studio_10162023/dao/data_access.dart';
import 'package:kitchen_studio_10162023/model/recipe.dart';
import 'package:kitchen_studio_10162023/service/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class RecipeDataAccess implements DataAccess<Recipe> {
  Database? database;

  RecipeDataAccess._privateConstructor() {
    database = DatabaseService.instance.connectedDatabase;
  }

  static final RecipeDataAccess _instance =
      RecipeDataAccess._privateConstructor();

  static RecipeDataAccess get instance => _instance;

  @override
  Future<int?> create(Recipe t) async {
    return database?.insert(Recipe.tableName(), {
      'recipe_name': t.recipeName,
      'author': t.author,
      'type_handler': t.typeHandler,
      'estimated_time_completion': t.estimatedTimeCompletion,
      'rating': t.rating,
      'cook_count': t.cookCount,
      'image_file_path': t.imageFilePath,
    });
  }

  @override
  Future<int?> delete(int id) async {
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
        Recipe.tableName(),
        {
          'recipe_name': t.recipeName,
          'author': t.author,
          'type_handler': t.typeHandler,
          'estimated_time_completion': t.estimatedTimeCompletion,
          'rating': t.rating,
          'cook_count': t.cookCount,
          'image_file_path': t.imageFilePath,
        },
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
