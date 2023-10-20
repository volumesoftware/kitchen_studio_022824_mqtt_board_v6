import 'package:kitchen_studio_10162023/model/instruction.dart';

class PumpOilOperation implements BaseOperation {
  static int CODE = 209;

  @override
  int? id;

  @override
  int? recipeId;
  @override
  int? operation = 209;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  int? duration;

  PumpOilOperation(
      {
        this.id,
        this.recipeId,
        this.currentIndex,
        this.instructionSize,
        this.targetTemperature,
        this.duration});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Pumping Oil';
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['targetTemperature'] = targetTemperature;
    data['duration'] = duration;
    return data;
  }

  PumpOilOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    duration = json['duration'];
    targetTemperature = json['target_temperature'];
  }

}

