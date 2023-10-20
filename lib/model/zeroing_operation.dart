import 'package:kitchen_studio_10162023/model/instruction.dart';

class ZeroingOperation implements BaseOperation {
  static int CODE = 199;

  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = 199;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;

  ZeroingOperation(
      {this.id, this.recipeId, this.currentIndex, this.instructionSize, this.targetTemperature});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Zeroing';
    data['operation'] = operation;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    return data;
  }

  ZeroingOperation.fromJson(Map<String, dynamic> json) {
    operation = json['operation'];
    currentIndex = json['current_index'];
    instructionSize = json['instruction_size'];
    targetTemperature = json['target_temperature'];
  }
}
