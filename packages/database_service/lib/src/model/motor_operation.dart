import 'package:flutter/src/widgets/icon_data.dart';

import 'models.dart';

class MotorOperation implements BaseOperation {
  static const int CODE = 7777;

  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = MotorOperation.CODE;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;
  @override
  String? requestId = 'Motor Operation';
  int? relativeTiltAngle;
  int? relativeRotateAngle;

  MotorOperation(
      this.targetTemperature, this.relativeTiltAngle, this.relativeRotateAngle);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = requestId;
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['relative_tilt_angle'] = relativeTiltAngle;
    data['relative_rotate_angle'] = relativeRotateAngle;
    data['preset_name'] = presetName;

    return data;
  }

  MotorOperation.fromDatabase(Map<String, Object?> json) {
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
    presetName =json['preset_name']==null? null: json['preset_name'] as String;

  }

  @override
  String? presetName;

  @override
  IconData? iconData;
}
