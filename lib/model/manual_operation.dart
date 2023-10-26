import 'package:kitchen_studio_10162023/model/instruction.dart';

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
    return data;
  }


  ManualOperation.fromDatabase(Map<String, Object?> json) {
    id = json['id'] as int;
    recipeId = json['recipe_id']==null? null: json['recipe_id'] as int;
    operation = json["operation"] == null ? null : json["operation"] as int;
    currentIndex = json["current_index"]==null? null: json["current_index"] as int;
    instructionSize =json["instruction_size"]==null? null: json["instruction_size"] as int;
    targetTemperature = json["target_temperature"]==null? null: json["target_temperature"] as double;
    message = json["message"] == null ? null:  json['message'] as String;
    title = json["title"] == null ? null:  json['title'] as String;
  }




}
