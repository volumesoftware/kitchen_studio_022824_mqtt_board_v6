import 'package:kitchen_studio_10162023/model/instruction.dart';

class WashOperation implements BaseOperation {
  static int CODE = 202;
  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = 202;
  int? duration;
  int? cycle;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;

  WashOperation(
      {this.id,
      this.recipeId,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.duration,
      this.cycle});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Washing';
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['duration'] = duration;
    data['cycle'] = cycle;
    return data;
  }

  WashOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    cycle = json['cycle'];
    duration = json['duration'];
    targetTemperature = json['target_temperature'];
  }
}
