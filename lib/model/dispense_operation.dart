import 'package:kitchen_studio_10162023/model/instruction.dart';

class DispenseOperation implements BaseOperation {
  static const int CODE = 203;
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
  @override
  String? requestId = 'Dispensing';



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
    data['request_id'] = requestId;
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['cycle'] = cycle;
    return data;
  }

  DispenseOperation.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    recipeId = json['recipe_id']==null? null: json['recipe_id'] as int;
    operation = json['operation']== null? 0: json['operation'] as int;
    currentIndex = json["current_index"]==null? null: json["current_index"] as int;
    instructionSize =json["instruction_size"]==null? null: json["instruction_size"] as int;
    targetTemperature = json["target_temperature"]==null? null: json["target_temperature"] as double;
    cycle = json["cycle"] == null? 0 : json["cycle"] as int;
  }

}
