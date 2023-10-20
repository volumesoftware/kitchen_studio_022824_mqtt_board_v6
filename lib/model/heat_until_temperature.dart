import 'package:kitchen_studio_10162023/model/instruction.dart';

class HeatUntilTemperatureOperation implements BaseOperation {
  static int CODE = 208;

  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = 208;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;

  HeatUntilTemperatureOperation(
      {this.id, this.recipeId, this.currentIndex, this.instructionSize, this.targetTemperature});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Heating to temperature';
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['targetTemperature'] = targetTemperature;
    return data;
  }

  HeatUntilTemperatureOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    targetTemperature = json['target_temperature'];
  }

}
