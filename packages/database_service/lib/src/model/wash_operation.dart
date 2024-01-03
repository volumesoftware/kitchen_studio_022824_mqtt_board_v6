import 'package:flutter/material.dart';

import 'models.dart';

class WashOperation extends TimedOperation {
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

  double? tiltAngleA;

  double? tiltAngleB;

  double? rotateAngle;

  int? tiltSpeed;

  int? rotateSpeed;
  IconData? iconData = Icons.waves_sharp;

  WashOperation(
      {this.id,
      this.recipeId,
      this.cycle,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.duration,
      this.tiltAngleA,
      this.tiltAngleB,
      this.rotateAngle,
      this.rotateSpeed,
      this.tiltSpeed});

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

    data['tilt_angle_a'] = tiltAngleA;
    data['tilt_angle_b'] = tiltAngleB;
    data['rotate_angle'] = rotateAngle;
    data['rotate_speed'] = rotateSpeed;
    data['tilt_speed'] = tiltSpeed;
    return data;
  }

  WashOperation.fromDatabase(Map<String, Object?> json) {
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
    cycle = json["cycle"] == null ? null : json["cycle"] as int;

    tiltAngleA =
        json["tilt_angle_a"] == null ? null : json["tilt_angle_a"] as double;
    tiltAngleB =
        json["tilt_angle_b"] == null ? null : json["tilt_angle_b"] as double;
    rotateAngle =
        json["rotate_angle"] == null ? null : json["rotate_angle"] as double;
    rotateSpeed =
        json["rotate_speed"] == null ? null : json["rotate_speed"] as int;
    tiltSpeed = json["tilt_speed"] == null ? null : json["tilt_speed"] as int;
  }
}
