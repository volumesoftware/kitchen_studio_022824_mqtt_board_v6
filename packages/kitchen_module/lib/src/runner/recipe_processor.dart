import 'dart:async';
import 'dart:isolate';
import 'package:database_service/database_service.dart';
import 'package:kitchen_module/kitchen_module.dart';

class RecipeProcessor {
  bool _isInitialized = false;
  String? moduleName;
  bool _busy = false;
  late DateTime lastStateChangeTime;
  late DateTime taskStarted;
  int etaInSeconds = 0;
  Timer? timer;

  Set<String?> lastErrors = Set();

  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;
  BaseOperationDataAccess baseOperationDataAccess =
      BaseOperationDataAccess.instance;
  StreamController<DeviceStats> _deviceStateChange =
      StreamController<DeviceStats>.broadcast();
  StreamController<DeviceStats> _heartBeatChange =
      StreamController<DeviceStats>.broadcast();

  DeviceStats _device;
  late Isolate _isolate;
  late SendPort _sendPort;
  late ReceivePort _receivePort;

  final List<TaskListener> _eventListeners = [];

  TaskPayload? _payload;
  double _progress = 0.0;
  int _index = 0;
  bool _chain = false;
  bool _notStateChangeOccured = false;

  RecipeProcessor(this._device) {
    moduleName = _device.moduleName;
    lastStateChangeTime = DateTime.now();

    _stateChanges.listen((deviceStats) {
      DateTime currentTime = DateTime.now();
      if (currentTime.difference(lastStateChangeTime) >= Duration(seconds: 5)) {
        _notStateChangeOccured = true;
      } else {
        _notStateChangeOccured = false;
      }
      if (deviceStats.lastError != null) {
        if (deviceStats.lastError!.isNotEmpty) {
          lastErrors.add(deviceStats.lastError);
        }
      }
      lastStateChangeTime = DateTime.now();
      _heartBeatChange.sink.add(deviceStats);
    });

    Timer.periodic(Duration(seconds: 2), (_) {
      DateTime currentTime = DateTime.now();
      if (currentTime.difference(lastStateChangeTime) >= Duration(seconds: 5)) {
        _notStateChangeOccured = true;
      } else {
        _notStateChangeOccured = false;
      }
      _heartBeatChange.sink.add(_device);
    });

    if (!_isInitialized) {
      _initIsolate();
      _isInitialized = true;
    }
  }

  //listen to the state change of the thread pool
  Stream<DeviceStats> get _stateChanges => _deviceStateChange.stream;

  Stream<DeviceStats> get hearBeat => _heartBeatChange.stream;

  //listen to the state change of the thread pool
  bool get noStateChange => _notStateChangeOccured;

  void _initIsolate() async {
    _receivePort = ReceivePort();
    _receivePort.listen((message) async {
      print(message);

      if (message is String) {
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
            taskStarted = DateTime.now();
            const oneSec = const Duration(seconds: 1);
            timer = new Timer.periodic(
              oneSec,
                  (Timer timer) {
                if (etaInSeconds == 0) {
                  timer.cancel();
                } else {
                  etaInSeconds = etaInSeconds - 1;
                }
                print(etaInSeconds);

              },
            );
            _payload!.task.status = Task.STARTED;
            await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
          }
        }
      } else if (message is TaskProgress) {
        _progress = message.progress;
      } else if (message is IndexProgress) {
        _index = message.progress;
      } else if (message is UserAction) {
        print(message);
      } else if (message is UserResponse) {
        print(message);
      } else if (message is Exception) {
        _payload = null;
        _busy = false;
        _eventListeners.forEach((element) {
          element.onError(message);
        });
      } else if (message is KillIsolate) {
        // Isolate.kill(priority: Isolate.immediate);
      } else if (message is SendPort) {
        _sendPort = message;
        print('_sendPort assigned');
      }
    });

    _isolate =
        await Isolate.spawn(recipeIsolateEntryPoint, _receivePort.sendPort);
  }

  Future<void> processRecipe(TaskPayload p) async {
    int duration = 0;
    for (var i = 0; i < p.operations.length; i++) {
      BaseOperation operation = p.operations[i];

      if (operation is TimedOperation) {
        TimedOperation op = (operation) as TimedOperation;
        duration = duration + op.duration!;
      }

      if (operation.operation == RepeatOperation.CODE) {
        RepeatOperation repeater = (operation as RepeatOperation);
        Iterable<BaseOperation> _repeatSequence = p.operations.getRange(
            (repeater.repeatIndex!) > 0 ? (repeater.repeatIndex! - 1) : 0, i);

        for (var j = 0; j < repeater.repeatCount!; j++) {
          print("REPEAT ${j + 1}");
          for (BaseOperation _operation in _repeatSequence) {
            if (_operation is TimedOperation) {
              TimedOperation _op = (_operation) as TimedOperation;
              duration = duration + _op.duration!;
            }
          }
        }
      }
    }

    etaInSeconds = duration + 120;

    _payload = p;
    _sendPort.send([_receivePort.sendPort, p, _device]);
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

  BaseOperation? getCurrentOperation() {
    return _payload?.operations[_index];
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
    lastErrors.clear();
    _receivePort.close();
    _isolate.kill();
    timer?.cancel();
  }

  @override
  String toString() {
    return moduleName ?? 'Unknown';
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
