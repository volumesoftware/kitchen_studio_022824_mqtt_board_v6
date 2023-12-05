import 'dart:async';
import 'dart:isolate';
import 'package:database_service/database_service.dart';
import 'package:kitchen_module/kitchen_module.dart';

class RecipeProcessor {
  bool _isInitialized = false;
  String? moduleName;
  bool _busy = false;
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;
  BaseOperationDataAccess baseOperationDataAccess =
      BaseOperationDataAccess.instance;
  StreamController<DeviceStats> _deviceStateChange = StreamController<DeviceStats>.broadcast();

  DeviceStats _device;
  late Isolate _isolate;
  late SendPort _sendPort;
  late ReceivePort _receivePort;

  final List<TaskListener> _eventListeners = [];

  TaskPayload? _payload;
  double _progress = 0.0;
  int _index = 0;
  bool _chain = false;

  RecipeProcessor(this._device) {
    moduleName = _device.moduleName;

    if (!_isInitialized) {
      _initIsolate();
      _isInitialized = true;
    }
  }


  //listen to the state change of the thread pool
  Stream<DeviceStats> get stateChanges =>
      _deviceStateChange.stream;


  void _initIsolate() async {
    _receivePort = ReceivePort();
    _receivePort.listen((message) async {
      if (message == "completed") {
        _busy = false;
        _payload!.task.status = Task.COMPLETED;
        await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
        _payload = null;

        _eventListeners.forEach((element) {
          element.onEvent(_device.moduleName!, message,
              busy: _busy,
              deviceStats: _device,
              progress: _progress,
              index: _index);
        });
      } else if (message == "started") {
        _busy = true;
        if (_payload != null) {
          _payload!.task.status = Task.STARTED;
          await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
        }
        _eventListeners.forEach((element) {
          element.onEvent(_device.moduleName!, message,
              busy: _busy,
              deviceStats: _device,
              progress: _progress,
              index: _index);
        });
      } else if (message is TaskProgress) {
        _progress = message.progress;
        _eventListeners.forEach((element) {
          element.onEvent(_device.moduleName!, message,
              busy: _busy,
              deviceStats: _device,
              progress: _progress,
              index: _index);
        });
      } else if (message is IndexProgress) {
        _index = message.progress;
        _eventListeners.forEach((element) {
          element.onEvent(_device.moduleName!, message,
              busy: _busy,
              deviceStats: _device,
              progress: _progress,
              index: _index);
        });
      } else if (message is UserAction) {
        print(message);
        _eventListeners.forEach((element) {
          element.onEvent(_device.moduleName!, message,
              busy: _busy,
              deviceStats: _device,
              progress: _progress,
              index: _index,
              userAction: message);
        });
      } else if (message is UserResponse) {
        print(message);
        _eventListeners.forEach((element) {
          element.onEvent(_device.moduleName!, message,
              busy: _busy,
              deviceStats: _device,
              progress: _progress,
              index: _index);
        });
      } else if (message is Exception) {
        _payload = null;
        _busy = false;
        _eventListeners.forEach((element) {
          element.onError(message);
        });
      } else if (message is KillIsolate) {
        // Isolate.kill(priority: Isolate.immediate);
      } else if(message is SendPort){
        _sendPort = message;
        print('_sendPort assigned');
      }
    });

    _isolate = await Isolate.spawn(recipeIsolateEntryPoint, _receivePort.sendPort);

  }

  Future<void> processRecipe(TaskPayload p) async {
    _sendPort.send([_receivePort.sendPort, p]);
  }

  void updateStats(DeviceStats deviceStats) {
    _device = deviceStats;
    moduleName = _device.moduleName;
    _busy = _device.requestId != 'idle';

    _deviceStateChange.sink.add(deviceStats);

    _eventListeners.forEach((element) {
      element.onEvent(_device.moduleName!, 'Status update',
          busy: _busy,
          deviceStats: _device,
          progress: _progress,
          index: _index);
    });
  }

  String? getModuleName() {
    return moduleName;
  }

  bool isChained() {
    return _chain;
  }

  void setChained(bool chain) {
    _chain = chain;
    _eventListeners.forEach((element) {
      element.onEvent(_device.moduleName!, 'Status update',
          busy: _busy,
          deviceStats: _device,
          progress: _progress,
          index: _index);
    });
  }

  bool isBusy() {
    return _busy;
  }

  TaskPayload? getPayload() {
    return _payload;
  }

  double getProgress() {
    return _progress;
  }

  int getIndexProgress() {
    return _index;
  }

  DeviceStats getDeviceStats() {
    return _device;
  }

  void addListeners(TaskListener listener) {
    _eventListeners.add(listener);
  }

  void removeListeners(TaskListener listener) {
    _eventListeners.remove(listener);
  }

  void dispose() {
    _receivePort.close();
    _isolate.kill();
  }
}

class TaskFailure implements Exception {}

class ConnectionFailure implements Exception {}

class KillIsolate {}

abstract interface class TaskListener {
  void onEvent(String moduleName, dynamic message,
      {required bool busy,
      required DeviceStats deviceStats,
      required double progress,
      required int index,
      UserAction? userAction});

  void onError(Exception error);
}
