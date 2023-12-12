// import 'dart:io';
//
// import 'package:kitchen_studio_10162023/model/device_stats.dart';
// import 'package:kitchen_studio_10162023/model/dock_ingredient_operation.dart';
// import 'package:kitchen_studio_10162023/model/ingredient.dart';
// import 'package:kitchen_studio_10162023/model/instruction.dart';
// import 'package:kitchen_studio_10162023/model/recipe.dart';
// import 'package:kitchen_studio_10162023/model/task.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
//
// class DatabaseService {
//   Database? database;
//
//   DatabaseService._privateConstructor();
//
//   static final DatabaseService _instance =
//       DatabaseService._privateConstructor();
//
//   static DatabaseService get instance => _instance;
//
//   Database get connectedDatabase => database!;
//
//   Future<void> initialize() async {
//     if (Platform.isWindows || Platform.isLinux) {
//       sqfliteFfiInit();
//     }
//
//     var databaseFactory = databaseFactoryFfi;
//     database =
//         await databaseFactory.openDatabase('/assets/database/kitchenstudio.db',
//             options: OpenDatabaseOptions(
//               version: 23,
//               onUpgrade: (db, oldVersion, newVersion) => createDrop(db, newVersion),
//               onCreate: (db, version) => createDrop(db, version),
//             ));
//     print(database?.path);
//     print(database?.getVersion());
//   }
//
//   Future<void> createDrop(Database db, int version) async {
//     print("creating database");
//     await db.execute(DeviceStats.dropCreateCommand());
//     await db.execute(Recipe.dropCreateCommand());
//     await db.execute(Ingredient.dropCreateCommand());
//     await db.execute(IngredientItem.dropCreateCommand());
//     await db.execute(BaseOperation.dropCreateCommand());
//     await db.execute(Task.dropCreateCommand());
//   }
// }
