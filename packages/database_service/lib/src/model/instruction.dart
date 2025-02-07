import 'package:flutter/material.dart';

abstract class BaseOperation {
  int? id;
  int? recipeId;
  int? operation;
  int? currentIndex;
  int? instructionSize;
  double? targetTemperature;
  String? requestId;
  String? presetName;
  IconData? iconData;

  BaseOperation(
      {this.id,
      this.currentIndex,
      this.instructionSize,
      this.targetTemperature});

  Map<String, dynamic> toJson();

  BaseOperation updateValue(Map<String, dynamic> json);


  static String tableName() {
    return 'Operation';
  }

  static String dropCreateCommand() {
    return '''
    DROP TABLE IF EXISTS ${BaseOperation.tableName()};
    CREATE TABLE ${BaseOperation.tableName()}(
        id INTEGER PRIMARY KEY,
        request_id INTEGER,
        instruction_size INTEGER,
        recipe_id INTEGER,
        operation INTEGER,
        current_index INTEGER,
        target_temperature FLOAT,
        volume FLOAT,
        cycle INTEGER,
        interval INTEGER,
        duration INTEGER,
        message INTEGER,
        title INTEGER,
        preset_name TEXT,
        is_closing BOOLEAN,
        require_user_permission BOOLEAN,
        repeat_index INTEGER,
        repeat_count INTEGER,
        tilt_angle_a FLOAT,
        tilt_angle_b FLOAT,
        rotate_angle FLOAT,
        rotate_speed INTEGER,
        tilt_speed INTEGER
    );
    ''';
  }
}
