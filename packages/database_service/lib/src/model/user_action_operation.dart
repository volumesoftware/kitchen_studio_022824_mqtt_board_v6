import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/icon_data.dart';

import 'models.dart';

class UserActionOperation implements BaseOperation {
  static const int CODE = 9277;

  @override
  int? id;
  @override
  int? recipeId;
  @override
  String? requestId = 'User Action';
  @override
  int? operation = UserActionOperation.CODE;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;
  String? title;
  String? message;
  bool? isClosing;

  UserActionOperation(
      {this.recipeId,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature,
      this.title,
      this.message,
      this.isClosing});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_id'] = requestId;
    data['operation'] = operation;
    data['recipe_id'] = recipeId;
    data['current_index'] = currentIndex;
    data['instruction_size'] = instructionSize;
    data['target_temperature'] = targetTemperature;
    data['message'] = message;
    data['title'] = title;
    data['is_closing'] = isClosing == true ? 1 : 0;
    data['preset_name'] = presetName;

    return data;
  }

  UserActionOperation.fromDatabase(Map<String, Object?> json) {
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
    message = json["message"] == null ? null : json["message"] as String;
    title = json["title"] == null ? null : json["title"] as String;
    isClosing = json["is_closing"] == 0 ? false : true;
    presetName =json['preset_name']==null? null: json['preset_name'] as String;

  }

  @override
  String? presetName;

  @override
  IconData? iconData = Icons.person_2_rounded;
}
