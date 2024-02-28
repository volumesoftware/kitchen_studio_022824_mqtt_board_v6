
import 'package:flutter/src/widgets/icon_data.dart';

import 'models.dart';
class ManualOperation implements BaseOperation {

  static const int CODE = 60000;

  @override
  int? id;
  @override
  int? recipeId;
  @override
  int? operation = ManualOperation.CODE;
  @override
  int? currentIndex;
  @override
  int? instructionSize;
  @override
  double? targetTemperature;
  @override
  String? requestId = 'Setup';
  String? message;
  String? title;



  ManualOperation(
      {this.id, this.recipeId, this.currentIndex, this.instructionSize, this.targetTemperature, this.title, this.message});

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
    data['preset_name'] = presetName;

    return data;
  }


  ManualOperation.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    requestId =json['request_id']==null? null: json['request_id'] as String;
    recipeId = json['recipe_id']==null? null: json['recipe_id'] as int;
    operation = json["operation"] == null ? null : json["operation"] as int;
    currentIndex = json["current_index"]==null? null: json["current_index"] as int;
    instructionSize =json["instruction_size"]==null? null: json["instruction_size"] as int;
    targetTemperature = json["target_temperature"]==null? null: json["target_temperature"] as double;
    message = json["message"] == null ? null:  json['message'] as String;
    title = json["title"] == null ? null:  json['title'] as String;
    presetName =json['preset_name']==null? null: json['preset_name'] as String;

  }

  @override
  String? presetName;

  @override
  IconData? iconData;

  @override
  BaseOperation updateValue(Map<String, dynamic> json) {
    id = json['id'] == null ? id : json['id'] as int;
    requestId =json['request_id']==null? requestId: json['request_id'] as String;
    recipeId = json['recipe_id']==null? recipeId: json['recipe_id'] as int;
    operation = json["operation"] == null ? operation : json["operation"] as int;
    currentIndex = json["current_index"]==null? currentIndex: json["current_index"] as int;
    instructionSize =json["instruction_size"]==null? instructionSize: json["instruction_size"] as int;
    targetTemperature = json["target_temperature"]==null? targetTemperature: json["target_temperature"] as double;
    message = json["message"] == null ? message:  json['message'] as String;
    title = json["title"] == null ? title:  json['title'] as String;
    presetName =json['preset_name']==null? presetName: json['preset_name'] as String;

    return this;
  }




}
