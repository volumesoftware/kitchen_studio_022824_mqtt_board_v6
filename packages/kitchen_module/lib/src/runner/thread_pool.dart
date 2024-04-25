import 'dart:async';

import 'package:kitchen_module/kitchen_module.dart';

class ThreadPool {
  bool _initialized = false;

  ThreadPool._privateConstructor() {
    if (!_initialized) {
      _kmp.stateChanges.listen((Map<String, ModuleResponse> moduleResponse) {
        for (var device in moduleResponse.entries) {
          bool exist = false;
          for (var processor in _pool) {
            if (processor.moduleName() == device.value.moduleName) {
              exist = true;
              processor.updateStats(device.value);
            }
          }

          if (!exist) {
            _pool.add((device.value is StirFryResponse) ? RecipeProcessor(device.value) : TransporterProcessor(device.value));
            _pool.sort(
              (a, b) => a.moduleName().compareTo(b.moduleName()),
            );
            _poolChangeController.sink.add(_pool);
          } else {
            _poolChangeController.sink.add(_pool);
          }
        }
      });

      _initialized = true;
    }
  }

  static final ThreadPool _instance = ThreadPool._privateConstructor();

  static ThreadPool get instance => _instance;

  final KitchenModulePool _kmp = KitchenModulePool.instance;
  late final List<KitchenToolProcessor> _pool = [];
  final StreamController<List<KitchenToolProcessor>> _poolChangeController = StreamController<List<KitchenToolProcessor>>.broadcast();

  //listen to the state change of the thread pool
  Stream<List<KitchenToolProcessor>> get stateChanges => _poolChangeController.stream;

  int get poolSize => _pool.length;

  List<KitchenToolProcessor> get pool => _pool;

  void dispose() {
    for (var processor in _pool) {
      processor.dispose();
    }
  }

  void pop(KitchenToolProcessor kitchenToolProcessor) {
    kitchenToolProcessor.dispose();
    _pool.removeWhere((rp) => rp.moduleName == kitchenToolProcessor.moduleName);
  }
}
