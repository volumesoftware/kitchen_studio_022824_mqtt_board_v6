import 'package:kitchen_studio_10162023/model/instruction.dart';

class FlipOperation implements BaseOperation {
  static int CODE = 213;

  @override
  int? id;

  @override
  int? recipeId;
  @override
  int? operation = 213;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  int? cycle;
  int? interval;

  FlipOperation(
      {this.id,
      this.recipeId,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.cycle,
      this.interval});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Flipping';
    data['operation'] = operation;
    data['targetTemperature'] = targetTemperature;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['cycle'] = cycle;
    data['interval'] = interval;
    return data;
  }

  FlipOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    targetTemperature = json['target_temperature'];
    instructionSize = json['instruction_size'];
    cycle = json['cycle'];
    interval = json['interval'];
  }
}
