import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'api/api.dart';
import 'model/models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart' as fl;
import 'dart:async' show Future;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf/shelf.dart';
class DatabasePackage {
  Database? database;

  DatabasePackage._privateConstructor();

  static final DatabasePackage _instance = DatabasePackage._privateConstructor();

  static DatabasePackage get instance => _instance;

  Database get connectedDatabase => database!;

  Middleware createCorsHeadersMiddleware({Map<String, String> corsHeaders = const {
    'Access-Control-Allow-Origin': '*', // Allows access from any origin
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS', // Specifies allowed methods
    'Access-Control-Allow-Headers': '*', // Allows all headers
  }}) {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          // Handle pre-flight requests for CORS
          return Response.ok('', headers: corsHeaders);
        }
        final response = await innerHandler(request);
        // Add CORS headers to the response
        return response.change(headers: corsHeaders);
      };
    };
  }

  Future<void> initialize() async {
    fl.applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    if (Platform.isWindows || Platform.isLinux) { 
      sqfliteFfiInit();
    }

    final Directory tempDir = await getTemporaryDirectory();
    String path = "${tempDir.path}\\kitchen\\assets\\database";
    Directory myNewDir = await Directory('$path').create(recursive: true);

    var databaseFactory = databaseFactoryFfi;


    database = await databaseFactory.openDatabase('${path}\\kitchenstudio.db',
        options: OpenDatabaseOptions(
          version: 5,
          onUpgrade: (db, oldVersion, newVersion) => createDrop(db, newVersion),
          onDowngrade: (db, oldVersion, newVersion) => createDrop(db, newVersion),
          onCreate: (db, version) => createDrop(db, version),
        ));

    final service = ApiService();
    var handler = const Pipeline()
        .addMiddleware(createCorsHeadersMiddleware())
        .addHandler(service.handler);
    var server = await shelf_io.serve(handler, 'localhost', 80);

  }

  Future<void> createDrop(Database db, int version) async {
    await db.execute(AdvancedOperationItem.dropCreateCommand());
    // await db.execute(DeviceStats.dropCreateCommand());
    await db.execute(Recipe.dropCreateCommand());
    await db.execute(Ingredient.dropCreateCommand());
    await db.execute(IngredientItem.dropCreateCommand());
    await db.execute(BaseOperation.dropCreateCommand());
    await db.execute(OperationTemplate.dropCreateCommand());
    await db.execute(OperationTemplateItem.dropCreateCommand());
    await db.execute(Task.dropCreateCommand());
    await db.execute(SystemSettings.dropCreateCommand());


  }
}
