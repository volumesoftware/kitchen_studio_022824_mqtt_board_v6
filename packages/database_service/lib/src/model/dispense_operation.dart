
import 'package:flutter/material.dart';

import 'models.dart';

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

  double? tiltAngleA;

  double? tiltAngleB;

  double? rotateAngle;

  int? tiltSpeed;

  int? rotateSpeed;

  IconData? iconData = Icons.account_tree_outlined;



  DispenseOperation(
      {this.id,
      this.recipeId,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.cycle,
        this.tiltAngleA,
        this.tiltAngleB,
        this.rotateAngle,
        this.rotateSpeed,
        this.tiltSpeed
      });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['preset_name'] = presetName;
    data['request_id'] = requestId;
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['cycle'] = cycle;

    data['tilt_angle_a'] = tiltAngleA;
    data['tilt_angle_b'] = tiltAngleB;
    data['rotate_angle'] = rotateAngle;
    data['rotate_speed'] = rotateSpeed;
    data['tilt_speed'] = tiltSpeed;
    return data;
  }

  DispenseOperation.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    requestId =json['request_id']==null? null: json['request_id'] as String;
    presetName =json['preset_name']==null? null: json['preset_name'] as String;
    recipeId = json['recipe_id']==null? null: json['recipe_id'] as int;
    operation = json['operation']== null? 0: json['operation'] as int;
    currentIndex = json["current_index"]==null? null: json["current_index"] as int;
    instructionSize =json["instruction_size"]==null? null: json["instruction_size"] as int;
    targetTemperature = json["target_temperature"]==null? null: json["target_temperature"] as double;
    cycle = json["cycle"] == null? 0 : json["cycle"] as int;

    tiltAngleA = json["tilt_angle_a"]==null? null: json["tilt_angle_a"] as double;
    tiltAngleB = json["tilt_angle_b"]==null? null: json["tilt_angle_b"] as double;
    rotateAngle = json["rotate_angle"]==null? null: json["rotate_angle"] as double;
    rotateSpeed = json["rotate_speed"]==null? null: json["rotate_speed"] as int;
    tiltSpeed = json["tilt_speed"]==null? null: json["tilt_speed"] as int;
  }

  @override
  String? presetName;

}
