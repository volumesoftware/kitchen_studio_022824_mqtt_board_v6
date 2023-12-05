
import 'models.dart';
class FlipOperation implements BaseOperation {
  static const int CODE = 213;

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
  @override
  String? requestId = 'Flipping';



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
    data['request_id'] = requestId;
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['cycle'] = cycle;
    data['interval'] = interval;
    return data;
  }

  FlipOperation.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    requestId =json['request_id']==null? null: json['request_id'] as String;
    recipeId = json['recipe_id']==null? null: json['recipe_id'] as int;
    operation = json["operation"] == null ? null : json["operation"] as int;
    currentIndex = json["current_index"]==null? null: json["current_index"] as int;
    instructionSize =json["instruction_size"]==null? null: json["instruction_size"] as int;
    targetTemperature = json["target_temperature"]==null? null: json["target_temperature"] as double;
    cycle = json["cycle"] == null? 0 : json["cycle"] as int;
    interval = json["interval"] == null? 0 : json["interval"] as int;
  }

}
