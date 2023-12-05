import 'package:database_service/database_service.dart';

class TaskPayload {
  final Recipe recipe;
  final List<BaseOperation> operations;
  final DeviceStats deviceStats;
  final Task task;
  final bool randomAssign;

  TaskPayload(this.recipe, this.operations, this.deviceStats, this.task, this.randomAssign);
}
