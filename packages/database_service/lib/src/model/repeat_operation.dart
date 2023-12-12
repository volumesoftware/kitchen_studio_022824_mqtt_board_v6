import 'models.dart';

class RepeatOperation implements BaseOperation {
  static const int CODE = 9273401;

  @override
  int? id;
  @override
  int? recipeId;
  @override
  String? requestId = 'Repeat Action';
  @override
  int? operation = RepeatOperation.CODE;
  @override
  int? currentIndex;
  @override
  double? targetTemperature;
  @override
  int? instructionSize;
  int? repeatIndex;
  int? repeatCount;

  RepeatOperation(
      {this.recipeId,
      this.currentIndex,
      this.instructionSize,
      this.repeatIndex,
      this.repeatCount});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = requestId;
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['repeat_index'] = repeatIndex;
    data['repeat_count'] = repeatCount;
    return data;
  }

  RepeatOperation.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    requestId =
        json['request_id'] == null ? null : json['request_id'] as String;
    recipeId = json['recipe_id'] == null ? null : json['recipe_id'] as int;
    currentIndex =
        json["current_index"] == null ? null : json["current_index"] as int;
    instructionSize = json["instruction_size"] == null
        ? null
        : json["instruction_size"] as int;
    targetTemperature = json["target_temperature"] == null
        ? null
        : json["target_temperature"] as double;

    repeatCount =
        json["repeat_count"] == null ? null : json["repeat_count"] as int;
    repeatIndex =
        json["repeat_index"] == null ? null : json["repeat_index"] as int;
  }
}
