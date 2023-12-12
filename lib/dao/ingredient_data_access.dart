// import 'package:kitchen_studio_10162023/dao/data_access.dart';
// import 'package:kitchen_studio_10162023/model/ingredient.dart';
// import 'package:kitchen_studio_10162023/service/database_service.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
//
// class IngredientDataAccess implements DataAccess<Ingredient> {
//   Database? database;
//
//   IngredientDataAccess._privateConstructor() {
//     database = DatabaseService.instance.connectedDatabase;
//   }
//
//   static final IngredientDataAccess _instance =
//       IngredientDataAccess._privateConstructor();
//
//   static IngredientDataAccess get instance => _instance;
//
//   @override
//   Future<int?> create(Ingredient t) async {
//     return database?.insert(Ingredient.tableName(), t.toJson());
//   }
//
//   @override
//   Future<int?> delete(int id) async {
//     return database
//         ?.delete(Ingredient.tableName(), where: "id = ?", whereArgs: [id]);
//   }
//
//   @override
//   Future<List<Ingredient>?> findAll() async {
//     var list =
//         await database?.rawQuery('SELECT * FROM ${Ingredient.tableName()}');
//     return list?.map((e) => Ingredient.fromDatabase(e)).toList();
//   }
//
//   @override
//   Future<Ingredient?> getById(int id) async {
//     return (await database
//             ?.query(Ingredient.tableName(), where: "id = ?", whereArgs: [id]))
//         ?.map((e) => Ingredient.fromDatabase(e))
//         .first;
//   }
//
//   @override
//   Future<Ingredient?> updateById(int id, Ingredient t) async {
//     int? count = await database?.update(
//         Ingredient.tableName(), t.toJson(),
//         where: "id = ?",
//         whereArgs: [id]);
//
//     if (count != null) {
//       if (count > 0) return getById(id);
//     }
//     return null;
//   }
//
//   @override
//   Future<List<Ingredient>?> search(String? where,
//       {List<Object>? whereArgs}) async {
//     var list = await database?.query(Ingredient.tableName(),
//         whereArgs: whereArgs, where: where);
//     return list?.map((e) => Ingredient.fromDatabase(e)).toList();
//   }
// }
