import 'package:database_service/database_service.dart';
import 'package:flutter/cupertino.dart';

class TaskPayload {
  final Recipe recipe;
  final List<BaseOperation> operations;
  final Task task;

  TaskPayload(this.recipe, this.operations, this.task);
}
