import 'dart:async';

import 'package:database_service/src/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class BaseOperationDataAccess implements DataAccess<BaseOperation> {
  Database? database;

  BaseOperationDataAccess._privateConstructor() {
    database = DatabasePackage.instance.connectedDatabase;
  }

  static final BaseOperationDataAccess _instance =
      BaseOperationDataAccess._privateConstructor();

  static BaseOperationDataAccess get instance => _instance;

  Future<BaseOperation> _fullMap(Map<String, Object?> e) async{
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
      case StirOperation.CODE:
        return StirOperation.fromDatabase(e);
      case UserActionOperation.CODE:
        return UserActionOperation.fromDatabase(e);
      case HotMixOperation.CODE:
        return HotMixOperation.fromDatabase(e);
      case ColdMixOperation.CODE:
        return ColdMixOperation.fromDatabase(e);
      case RepeatOperation.CODE:
        return RepeatOperation.fromDatabase(e);
      case AdvancedOperation.CODE:
        List<Map<String, Object?>>? items = await database?.query(AdvancedOperationItem.tableName(),
            whereArgs: [e['id']], where: "operation_id = ?");
        return AdvancedOperation.fromDatabase(e, controlItems: items?.map((k) => AdvancedOperationItem.fromDatabase(k)).toList());
    }

    return ZeroingOperation.fromDatabase(e);
  }

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
      case StirOperation.CODE:
        return StirOperation.fromDatabase(e);
      case UserActionOperation.CODE:
        return UserActionOperation.fromDatabase(e);
      case HotMixOperation.CODE:
        return HotMixOperation.fromDatabase(e);
      case ColdMixOperation.CODE:
        return ColdMixOperation.fromDatabase(e);
      case RepeatOperation.CODE:
        return RepeatOperation.fromDatabase(e);
      case AdvancedOperation.CODE:
        return AdvancedOperation.fromDatabase(e);
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
    var list = await database?.rawQuery('SELECT * FROM ${BaseOperation.tableName()}') ?? [];
    return  list.map((e) => _map(e)).toList();
  }

  @override
  Future<BaseOperation?> getById(int id) async {
    return (await database?.query(BaseOperation.tableName(),
            where: "id = ?", whereArgs: [id]))
        ?.map((e) => _fullMap(e))
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
