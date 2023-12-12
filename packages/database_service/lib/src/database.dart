import 'dart:io';

import 'model/models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart' as fl;


class DatabasePackage {
  Database? database;

  DatabasePackage._privateConstructor();

  static final DatabasePackage _instance =
  DatabasePackage._privateConstructor();

  static DatabasePackage get instance => _instance;

  Database get connectedDatabase => database!;

  Future<void> initialize() async {

    fl.applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

    if (Platform.isWindows || Platform.isLinux) {
      print("initializing");
      sqfliteFfiInit();
    }

    var databaseFactory = databaseFactoryFfi;

    database = await databaseFactory.openDatabase('/assets/database/kitchenstudio.db',
        options: OpenDatabaseOptions(
          version: 26,
          onUpgrade: (db, oldVersion, newVersion) => createDrop(db, newVersion),
          onCreate: (db, version) => createDrop(db, version),
        ));
    print(database?.path);
    print(database?.getVersion());
  }

  Future<void> createDrop(Database db, int version) async {
    print("creating database");
    await db.execute(DeviceStats.dropCreateCommand());
    await db.execute(Recipe.dropCreateCommand());
    await db.execute(Ingredient.dropCreateCommand());
    await db.execute(IngredientItem.dropCreateCommand());
    await db.execute(BaseOperation.dropCreateCommand());
    await db.execute(Task.dropCreateCommand());
  }
}
