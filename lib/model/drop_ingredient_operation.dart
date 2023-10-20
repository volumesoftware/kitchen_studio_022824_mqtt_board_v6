import 'package:kitchen_studio_10162023/model/instruction.dart';

class DropIngredientOperation implements BaseOperation {
  static int CODE = 207;

  @override
  int? id;
  @override
  int? recipeId;
  int? cycle;
  @override
  int? operation = 207;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;

  DropIngredientOperation(
      {this.currentIndex,
        this.instructionSize,
        this.targetTemperature,
        this.cycle});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Dropping Ingredient';
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['cycle'] = cycle;
    return data;
  }

  DropIngredientOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    cycle = json['cycle'];
    targetTemperature = json['target_temperature'];
  }

}
