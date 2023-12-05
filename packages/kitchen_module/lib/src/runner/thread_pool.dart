import 'dart:async';

import 'package:database_service/database_service.dart';
import 'package:database_service/src/model/device_stats.dart';
import 'package:kitchen_module/kitchen_module.dart';

class ThreadPool {

  bool _initialized = false;

  ThreadPool._privateConstructor() {

    if(!_initialized){
      _kmp.stateChanges.listen((Map<String, DeviceStats> deviceStats) {

        for (var device in deviceStats.entries) {
          bool exist = false;

          _pool.forEach((RecipeProcessor processor) {
            if (processor.moduleName == device.value.moduleName) {
              exist = true;
              processor.updateStats(device.value);
            }
          });

          if (!exist) {
            _pool.add(RecipeProcessor(device.value));
            _pool.sort((a, b) => a.moduleName!.compareTo(b.moduleName!),);
            _poolChangeController.sink.add(_pool);
          }else{

          }
        }


      });

      _initialized = true;
    }

  }

  static final ThreadPool _instance = ThreadPool._privateConstructor();

  static ThreadPool get instance => _instance;

  late List<RecipeProcessor> _pool = [];
  KitchenModulePool _kmp = KitchenModulePool.instance;
  StreamController<List<RecipeProcessor>> _poolChangeController = StreamController<List<RecipeProcessor>>.broadcast();

  //listen to the state change of the thread pool
  Stream<List<RecipeProcessor>> get stateChanges =>
      _poolChangeController.stream;

  Future<void> submitRecipe(TaskPayload taskPayload) async {
    final availableProcessor = _pool.firstWhere(
        (processor) => ((!processor.isBusy()) && ((processor.moduleName == taskPayload.deviceStats.moduleName) || (taskPayload.randomAssign))),
        orElse: () => throw Exception('No available processors in the pool'));
    await availableProcessor.processRecipe(taskPayload);
  }

  void dispose() {
    _pool.forEach((processor) => processor.dispose());
  }

}
