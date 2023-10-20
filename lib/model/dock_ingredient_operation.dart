import 'package:kitchen_studio_10162023/model/ingredient.dart';
import 'package:kitchen_studio_10162023/model/instruction.dart';

class DockIngredientOperation implements BaseOperation {
  static int CODE = 206;

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


  DockIngredientOperation(
      {this.currentIndex, this.instructionSize, this.targetTemperature});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Docking Ingredient';
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    return data;
  }

  DockIngredientOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    targetTemperature = json['target_temperature'];
  }

  DockIngredientOperation.fromDatabase(Map<String, Object?> json, this.ingredientItems) {
    operation = json['operation']== null? 0: json['operation'] as int;
    currentIndex = json['current_index'] == null? 0 : json['current_index'] as int;
    instructionSize =  json['instruction_size'] == null? 0 : json['instruction_size'] as int;
    targetTemperature =  json['target_temperature'] == null? 0 : json['target_temperature'] as double;
  }

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
      {this.id,
        this.ingredientId,
        this.operationId,
        this.mode,
        this.quantity});

  IngredientItem.fromDatabase(Map<String, Object?> json, this.ingredient, this.operation) {
    id = json['id'] as int;
    mode = json['mode']== null? null: json['mode'] as String;
    ingredientId = json['ingredient_id']== null? 0: json['ingredient_id'] as int;
    operationId = json['operation_id']== null? 0: json['operation_id'] as int;
    quantity =json['quantity']== null? 0.0: json['quantity'] as double;
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
