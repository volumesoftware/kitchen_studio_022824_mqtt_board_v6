import 'package:kitchen_studio_10162023/model/instruction.dart';

class PumpWaterOperation implements BaseOperation {
  static int CODE = 210;

  @override
  int? id;

  @override
  int? recipeId;
  @override
  int? operation = 210;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  int? duration;

  PumpWaterOperation(
      {this.id,
      this.recipeId,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.duration});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Pumping Water';
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['targetTemperature'] = targetTemperature;
    data['duration'] = duration;
    return data;
  }

  PumpWaterOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    targetTemperature = json['target_temperature'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    duration = json['duration'];
  }
}
