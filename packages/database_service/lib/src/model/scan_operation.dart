import 'models.dart';

class ScanOperation implements BaseOperation {
  static const int CODE = 300;

  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = ScanOperation.CODE;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;
  @override
  String? requestId = 'Scanning';

  ScanOperation(
      {this.id,
      this.recipeId,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = requestId;
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    return data;
  }

  ScanOperation.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    requestId =
        json['request_id'] == null ? null : json['request_id'] as String;
    recipeId = json['recipe_id'] == null ? null : json['recipe_id'] as int;
    operation = json["operation"] == null ? null : json["operation"] as int;
    currentIndex =
        json["current_index"] == null ? null : json["current_index"] as int;
    instructionSize = json["instruction_size"] == null
        ? null
        : json["instruction_size"] as int;
    targetTemperature = json["target_temperature"] == null
        ? null
        : json["target_temperature"] as double;
  }
}
