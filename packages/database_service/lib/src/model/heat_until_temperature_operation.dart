import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';

import 'models.dart';

class HeatUntilTemperatureOperation implements BaseOperation {
  static const int CODE = 208;

  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = 208;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;
  @override
  String? requestId = 'Heating to temperature';
  double? tiltAngleA;

  HeatUntilTemperatureOperation({
    this.id,
    this.recipeId,
    this.currentIndex,
    this.instructionSize,
    this.targetTemperature,
    this.tiltAngleA,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = requestId;
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['tilt_angle_a'] = tiltAngleA;
    data['preset_name'] = presetName;


    return data;
  }

  HeatUntilTemperatureOperation.fromDatabase(Map<String, Object?> json) {
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
    tiltAngleA = json["tilt_angle_a"]==null? null: json["tilt_angle_a"] as double;
    presetName =json['preset_name']==null? null: json['preset_name'] as String;

  }

  @override
  String? presetName;

  @override
  IconData? iconData = Icons.thermostat;
}
