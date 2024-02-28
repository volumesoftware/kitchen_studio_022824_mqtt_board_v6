import 'dart:async';
import 'dart:isolate';
import 'package:kitchen_module/kitchen_module.dart';

class TransporterProcessor implements KitchenToolProcessor {
  bool _isInitialized = false;
  bool _busy = false;
  late DateTime lastStateChangeTime;
  late DateTime taskStarted;
  int etaInSeconds = 0;
  Timer? timer;
  static int IDLE_TIME = 10;

  Set<String?> lastErrors = Set();

  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;
  BaseOperationDataAccess baseOperationDataAccess =
      BaseOperationDataAccess.instance;
  StreamController<ModuleResponse> _deviceStateChange =
      StreamController<ModuleResponse>.broadcast();
  StreamController<ModuleResponse> _heartBeatChange =
      StreamController<ModuleResponse>.broadcast();

  ModuleResponse _device;
  late Isolate _isolate;
  late SendPort _sendPort;
  late ReceivePort _receivePort;

  HandlerPayload? _payload;
  double _progress = 0.0;
  int _index = 0;
  bool _chain = false;
  bool _notStateChangeOccured = false;

  TransporterProcessor(this._device) {
    lastStateChangeTime = DateTime.now();
    _stateChanges.listen((moduleResponse) {
      DateTime currentTime = DateTime.now();
      if (currentTime.difference(lastStateChangeTime) >=
          Duration(seconds: TransporterProcessor.IDLE_TIME)) {
        _notStateChangeOccured = true;
      } else {
        _notStateChangeOccured = false;
      }
      if (moduleResponse.lastError != null) {
        if (moduleResponse.lastError!.isNotEmpty) {
          lastErrors.add(moduleResponse.lastError);
        }
      }
      lastStateChangeTime = DateTime.now();
      _heartBeatChange.sink.add(moduleResponse);
    });

    Timer.periodic(Duration(seconds: 2), (_) {
      DateTime currentTime = DateTime.now();
      if (currentTime.difference(lastStateChangeTime) >=
          Duration(seconds: TransporterProcessor.IDLE_TIME)) {
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
  Stream<ModuleResponse> get _stateChanges => _deviceStateChange.stream;

  Stream<ModuleResponse> get hearBeat => _heartBeatChange.stream;

  //listen to the state change of the thread pool
  bool get noStateChange => _notStateChangeOccured;

  void _initIsolate() async {
    _receivePort = ReceivePort();
    _receivePort.listen((message) async {
      print(message);
      if (message is String) {
        if (message == "completed") {
          _busy = false;
          _payload = null;
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
              },
            );
            //   @todo do something here
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
      } else if (message is KillIsolate) {
        // Isolate.kill(priority: Isolate.immediate);
      } else if (message is SendPort) {
        _sendPort = message;
        // print('_sendPort assigned');
      }
    });

    _isolate = await Isolate.spawn(
        transporterIsolateEntryPoint, _receivePort.sendPort);
  }

  Future<void> process(HandlerPayload p) async {
    _payload = p;
    _sendPort.send([_receivePort.sendPort, p, _device]);
  }

  void updateStats(ModuleResponse moduleResponse) {
    _device = moduleResponse;
    _busy = _device.requestId != 'idle';
    _deviceStateChange.sink.add(moduleResponse);
  }

  bool isChained() {
    return _chain;
  }

  void setChained(bool chain) {
    _chain = chain;
  }

  bool isBusy() {
    return _busy;
  }

  IngredientHandlerPayload? getPayload() {
    return _payload as IngredientHandlerPayload;
  }

  double getProgress() {
    return _progress;
  }

  int getIndexProgress() {
    return _index;
  }

  ModuleResponse getModuleResponse() {
    return _device;
  }

  void dispose() {
    lastErrors.clear();
    _receivePort.close();
    _isolate.kill();
    timer?.cancel();
  }

  @override
  String toString() {
    return "${_device.type} ${moduleName()}";
  }

  @override
  String moduleName() {
    return _device.moduleName ?? "Unknown";
  }
}
