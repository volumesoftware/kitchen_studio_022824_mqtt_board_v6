import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';

import 'models.dart';



class AdvancedOperation implements BaseOperation {
  static const int CODE = 333;

  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = AdvancedOperation.CODE;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;
  @override
  String? requestId = 'Advanced Control';
  int? rotateSpeed;
  int? tiltSpeed;
  String? title;
  String? message;
  bool? requireUserPermission;

  List<AdvancedOperationItem> controlItems = [];


  AdvancedOperation(
      {this.currentIndex, this.instructionSize, this.targetTemperature});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = requestId;
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['preset_name'] = presetName;
    data['tilt_speed'] = tiltSpeed;
    data['rotate_speed'] = rotateSpeed;
    data['message'] = message;
    data['title'] = title;
    data['require_user_permission'] = requireUserPermission == true ? 1 : 0;
    return data;
  }

  Map<String, dynamic> toAdvancedJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Docking Ingredient';
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['preset_name'] = presetName;
    data['tilt_speed'] = tiltSpeed;
    data['rotate_speed'] = rotateSpeed;
    data['message'] = message;
    data['title'] = title;
    data['require_user_permission'] = requireUserPermission == true ? 1 : 0;
    var ingredientItemsMap = [];
    controlItems.forEach((element) {
      print(element.toString());
      ingredientItemsMap.add(element.toJson());
    });
    data['control_items'] = ingredientItemsMap;
    return data;
  }

  AdvancedOperation.fromDatabase(Map<String, Object?> json,
      {List<AdvancedOperationItem>? controlItems}) {
    this.controlItems = controlItems ?? [];
    id = json['id'] as int;
    presetName =
        json['preset_name'] == null ? null : json['preset_name'] as String;
    requestId =
        json['request_id'] == null ? null : json['request_id'] as String;
    recipeId = json['recipe_id'] as int;
    operation = json['operation'] == null ? 0 : json['operation'] as int;
    currentIndex =
        json['current_index'] == null ? 0 : json['current_index'] as int;
    instructionSize =
        json['instruction_size'] == null ? 0 : json['instruction_size'] as int;
    targetTemperature = json['target_temperature'] == null
        ? 0
        : json['target_temperature'] as double;
    rotateSpeed = json["rotate_speed"]==null? null: json["rotate_speed"] as int;
    tiltSpeed = json["tilt_speed"]==null? null: json["tilt_speed"] as int;
    message = json["message"] == null ? null : json["message"] as String;
    title = json["title"] == null ? null : json["title"] as String;
    requireUserPermission = json["require_user_permission"] == 0 ? false : true;

  }

  @override
  String? presetName;

  @override
  IconData? iconData = Icons.label;
}

enum OperationItemValueType {
  INTEGER,
  BOOLEAN,
  DOUBLE,
  STRING,
  NULL
}


enum OperationItemCodeEnum {
  TILT_MOTOR,
  ROTATING_MOTOR,
  BUCKET_MOTOR,
  WOK_VIBRATOR,
  OIL_PUMP,
  WATER_PUMP,
  USER_ACTION,
  TIMEOUT_WAIT,
  ZERO_TILT_MOTOR,
  ZERO_ROTATING_MOTOR,
  ZERO_BUCKET_MOTOR
}

class AdvancedOperationItem {
  int? id;
  int? operationId;
  double? doubleValue;
  int? integerValue;
  bool? booleanValue;
  String? stringValue;
  String? label;
  String? hint;
  OperationItemCodeEnum? operationItemCode;
  OperationItemValueType? valueType;

  AdvancedOperationItem(
      {this.operationId,
      this.doubleValue,
      this.integerValue,
      this.booleanValue,
      this.stringValue,
      this.operationItemCode,
        this.valueType,
      this.hint,
      this.label});

  Map<String, dynamic> toJson() {
    return {
      'operation_item_code': operationItemCode?.index,
      'value_type': valueType?.index,
      'operation_id': operationId,
      'double_value': doubleValue,
      'integer_value': integerValue,
      'boolean_value': booleanValue == true? 1 : 0,
      'string_value': stringValue,
      'label': label,
      'hint': hint,
    };
  }

  AdvancedOperationItem.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    operationItemCode = OperationItemCodeEnum.values[json['operation_item_code'] == null ? 0 :json['operation_item_code'] as int];
    valueType = OperationItemValueType.values[json['value_type'] == null ? 0 :json['value_type'] as int];
    operationId =
        json['operation_id'] == null ? 0 : json['operation_id'] as int;
    integerValue =
        json['integer_value'] == null ? 0 : json['integer_value'] as int;
    booleanValue = json['boolean_value'] == 0 ? false : true;
    doubleValue =
        json['double_value'] == null ? 0.0 : json['double_value'] as double;
    stringValue =
        json['string_value'] == null ? null : json['string_value'] as String;
    label = json['label'] == null ? null : json['label'] as String;
    hint = json['hint'] == null ? null : json['hint'] as String;
  }

  static String tableName() {
    return 'AdvancedOperationItem';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${AdvancedOperationItem.tableName()};
    CREATE TABLE ${AdvancedOperationItem.tableName()}(
        id INTEGER PRIMARY KEY,
        operation_item_code INTEGER,
        value_type INTEGER,
        operation_id INTEGER,
        integer_value INTEGER,
        boolean_value BOOLEAN,
        double_value FLOAT,
        string_value TEXT,
        label TEXT,
        hint TEXT
    );
    ''';
  }
}
