
import 'package:kitchen_studio_10162023/dao/data_access.dart';
import 'package:kitchen_studio_10162023/model/dispense_operation.dart';
import 'package:kitchen_studio_10162023/model/dock_ingredient_operation.dart';
import 'package:kitchen_studio_10162023/model/drop_ingredient_operation.dart';
import 'package:kitchen_studio_10162023/model/flip_operation.dart';
import 'package:kitchen_studio_10162023/model/heat_for_operation.dart';
import 'package:kitchen_studio_10162023/model/heat_until_temperature_operation.dart';
import 'package:kitchen_studio_10162023/model/instruction.dart';
import 'package:kitchen_studio_10162023/model/pump_oil_operation.dart';
import 'package:kitchen_studio_10162023/model/pump_water_operation.dart';
import 'package:kitchen_studio_10162023/model/scan_operation.dart';
import 'package:kitchen_studio_10162023/model/setup_operation.dart';
import 'package:kitchen_studio_10162023/model/wash_operation.dart';
import 'package:kitchen_studio_10162023/model/zeroing_operation.dart';
import 'package:kitchen_studio_10162023/service/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BaseOperationDataAccess implements DataAccess<BaseOperation> {
  Database? database;

  BaseOperationDataAccess._privateConstructor() {
    database = DatabaseService.instance.connectedDatabase;
  }

  static final BaseOperationDataAccess _instance =
      BaseOperationDataAccess._privateConstructor();

  static BaseOperationDataAccess get instance => _instance;

  BaseOperation _map(Map<String, Object?> e) {
    switch (e['operation'] as int) {
      case DispenseOperation.CODE:
        return DispenseOperation.fromDatabase(e);
      case DockIngredientOperation.CODE:
        return DockIngredientOperation.fromDatabase(e, []);
      case DropIngredientOperation.CODE:
        return DropIngredientOperation.fromDatabase(e);
      case FlipOperation.CODE:
        return FlipOperation.fromDatabase(e);
      case HeatForOperation.CODE:
        return HeatForOperation.fromDatabase(e);
      case HeatUntilTemperatureOperation.CODE:
        return HeatUntilTemperatureOperation.fromDatabase(e);
      case PumpOilOperation.CODE:
        return PumpOilOperation.fromDatabase(e);
      case PumpWaterOperation.CODE:
        return PumpWaterOperation.fromDatabase(e);
      case ScanOperation.CODE:
        return ScanOperation.fromDatabase(e);
      case SetupOperation.CODE:
        return SetupOperation.fromDatabase(e);
      case WashOperation.CODE:
        return WashOperation.fromDatabase(e);
      case ZeroingOperation.CODE:
        return ZeroingOperation.fromDatabase(e);
    }

    return ZeroingOperation.fromDatabase(e);
  }

  @override
  Future<int?> create(BaseOperation t) async {
    return database?.insert(BaseOperation.tableName(), t.toJson());
  }

  @override
  Future<int?> delete(int id) async {
    return database
        ?.delete(BaseOperation.tableName(), where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<BaseOperation>?> findAll() async {
    var list =
        await database?.rawQuery('SELECT * FROM ${BaseOperation.tableName()}');
    return list?.map((e) => _map(e)).toList();
  }

  @override
  Future<BaseOperation?> getById(int id) async {
    return (await database?.query(BaseOperation.tableName(),
            where: "id = ?", whereArgs: [id]))
        ?.map((e) => _map(e))
        .first;
  }

  @override
  Future<BaseOperation?> updateById(int id, BaseOperation t) async {
    int? count = await database?.update(BaseOperation.tableName(), t.toJson(),
        where: "id = ?", whereArgs: [id]);

    if (count != null) {
      if (count > 0) return getById(id);
    }
    return null;
  }

  @override
  Future<List<BaseOperation>?> search(String? where,
      {List<Object>? whereArgs}) async {
    var list = await database?.query(BaseOperation.tableName(),
        whereArgs: whereArgs, where: where);
    return list?.map((e) => _map(e)).toList();
  }
}
