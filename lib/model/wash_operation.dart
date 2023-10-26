import 'package:kitchen_studio_10162023/model/instruction.dart';

class WashOperation implements BaseOperation {
  static const int CODE = 202;
  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = WashOperation.CODE;
  int? duration;
  int? cycle;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;
  @override
  String? requestId = 'Wash';


  WashOperation(
      {this.id,
      this.recipeId,
      this.cycle,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.duration});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = requestId;
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;

    data['duration'] = duration;
    data['cycle'] = cycle;
    return data;
  }

  WashOperation.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    recipeId = json['recipe_id'] == null ? null : json['recipe_id'] as int;
    operation = json["operation"] == null ? null : json["operation"] as int;
    currentIndex = json["current_index"] == null ? null : json["current_index"] as int;
    instructionSize = json["instruction_size"] == null ? null : json["instruction_size"] as int;
    targetTemperature = json["target_temperature"] == null ? null : json["target_temperature"] as double;
    duration = json["duration"] == null ? null : json["duration"] as int;
    cycle = json["cycle"] == null ? null : json["cycle"] as int;
  }

}
