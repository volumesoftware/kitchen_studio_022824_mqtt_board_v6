import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models.dart';

class PumpOilOperation extends TimedOperation {
  static const int CODE = 209;

  @override
  int? id;

  @override
  int? recipeId;
  @override
  int? operation = PumpOilOperation.CODE;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  int? duration;

  IconData? iconData = Icons.water_drop;

  @override
  String? requestId = 'Pump Oil';


  PumpOilOperation(
      {this.id,
      this.recipeId,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.duration});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = 'Pump Oil';
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['duration'] = duration;
    data['preset_name'] = presetName;

    return data;
  }

  PumpOilOperation.fromDatabase(Map<String, Object?> json) {
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
    duration = json["duration"] == null ? null : json["duration"] as int;
    presetName =json['preset_name']==null? null: json['preset_name'] as String;

  }
}
