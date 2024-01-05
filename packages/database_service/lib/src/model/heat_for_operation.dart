
import 'package:flutter/material.dart';

import 'models.dart';
class HeatForOperation extends TimedOperation {
  static const int CODE = 212;
  @override
  int? id;

  @override
  int? recipeId;
  @override
  int? operation = 212;

  @override
  int? currentIndex;

  @override
  int? instructionSize;

  @override
  double? targetTemperature;

  int? duration;
  @override
  String? requestId = 'Timeout Heat';

  double? tiltAngleA;

  @override
  IconData? iconData = Icons.share_arrival_time_outlined;


      HeatForOperation(
      {
        this.id,
        this.recipeId,
        this.currentIndex,
        this.instructionSize,
        this.targetTemperature,
        this.duration,
        this.tiltAngleA});

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
    data['preset_name'] = presetName;

    data['tilt_angle_a'] = tiltAngleA;
    return data;
  }


  HeatForOperation.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    requestId =json['request_id']==null? null: json['request_id'] as String;
    recipeId = json['recipe_id']==null? null: json['recipe_id'] as int;
    operation = json["operation"] == null ? null : json["operation"] as int;
    currentIndex = json["current_index"]==null? null: json["current_index"] as int;
    instructionSize =json["instruction_size"]==null? null: json["instruction_size"] as int;
    targetTemperature = json["target_temperature"]==null? null: json["target_temperature"] as double;
    duration = json["duration"] == null? 0 : json["duration"] as int;
    presetName =json['preset_name']==null? null: json['preset_name'] as String;

    tiltAngleA = json["tilt_angle_a"]==null? null: json["tilt_angle_a"] as double;
  }


}
