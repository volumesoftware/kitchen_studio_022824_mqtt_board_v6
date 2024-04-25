import 'package:kitchen_module/kitchen_module.dart';

abstract interface class KitchenToolProcessor {
  Future<void> process(HandlerPayload payload);

  String moduleName();

  bool isBusy();

  dispose();

  void updateStats(ModuleResponse value);

  ModuleResponse getModuleResponse();
}

class TaskFailure implements Exception {}

class ConnectionFailure implements Exception {}

class KillIsolate {}

abstract interface class TaskListener {
  void onEvent(String moduleName, dynamic message,
      {required bool busy, required ModuleResponse moduleResponse, required double progress, required int index, UserAction? userAction});

  void onError(Exception error);
}
