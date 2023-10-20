import 'package:kitchen_studio_10162023/model/instruction.dart';

class DispenseOperation implements BaseOperation {
  static int CODE = 203;
  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = 203;
  int? cycle;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;

  DispenseOperation(
      {this.id,
      this.recipeId,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.cycle});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Dispensing';
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['targetTemperature'] = targetTemperature;
    data['cycle'] = cycle;
    return data;
  }

  DispenseOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    cycle = json['cycle'];
    targetTemperature = json['target_temperature'];
  }
}
