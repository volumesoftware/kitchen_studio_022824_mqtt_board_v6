import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';

import 'models.dart';

class DockIngredientOperation implements BaseOperation {
  static const int CODE = 206;

  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = 206;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;
  List<IngredientItem> ingredientItems = [];
  @override
  String? requestId = 'Docking Ingredient';

  DockIngredientOperation(
      {this.currentIndex, this.instructionSize, this.targetTemperature});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Docking Ingredient';
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['preset_name'] = presetName;

    return data;
  }

  DockIngredientOperation.fromDatabase(
      Map<String, Object?> json, this.ingredientItems) {
    id = json['id'] as int;
    presetName =json['preset_name']==null? null: json['preset_name'] as String;
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
  }

  @override
  String? presetName;

  @override
  IconData? iconData = Icons.dock_sharp;
}

class IngredientItem {
  int? id;
  int? ingredientId;
  int? operationId;
  double? quantity;
  String? mode;
  Ingredient? ingredient;
  DockIngredientOperation? operation;

  IngredientItem(
      {this.id, this.ingredientId, this.operationId, this.mode, this.quantity});

  IngredientItem.fromDatabase(
      Map<String, Object?> json, this.ingredient, this.operation) {
    id = json['id'] as int;
    mode = json['mode'] == null ? null : json['mode'] as String;
    ingredientId =
        json['ingredient_id'] == null ? 0 : json['ingredient_id'] as int;
    operationId =
        json['operation_id'] == null ? 0 : json['operation_id'] as int;
    quantity = json['quantity'] == null ? 0.0 : json['quantity'] as double;
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': ingredientId,
      'mode': mode,
      'operation_id': operationId,
      'quantity': quantity
    };
  }

  static String tableName() {
    return 'IngredientItem';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${IngredientItem.tableName()};
    CREATE TABLE ${IngredientItem.tableName()}(
        id INTEGER PRIMARY KEY,
        ingredient_id INTEGER,
        mode TEXT,
        operation_id INTEGER,
        quantity FLOAT
    );
    ''';
  }
}
