import 'dart:io';

import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  Database? database;

  DatabaseService._privateConstructor();

  static final DatabaseService _instance =
      DatabaseService._privateConstructor();

  static DatabaseService get instance => _instance;

  Database get connectedDatabase => database!;

  Future<void> initialize() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
    }

    var databaseFactory = databaseFactoryFfi;
    database =
        await databaseFactory.openDatabase('/assets/database/kitchenstudio.db',
            options: OpenDatabaseOptions(
              version: 3,
              onCreate: (db, version) => createDrop(db, version),
            ));
    print(database?.path);
    print(database?.getVersion());
    await database?.execute(DeviceStats.dropCreateCommand());


  }

  void createDrop(Database db, int version) async {
    print("creating database");
    await database?.execute(DeviceStats.dropCreateCommand());

  }
}
