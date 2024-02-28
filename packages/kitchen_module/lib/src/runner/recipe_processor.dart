import 'dart:async';
import 'dart:isolate';
import 'package:database_service/database_service.dart';
import 'package:kitchen_module/kitchen_module.dart';

class RecipeProcessor implements KitchenToolProcessor {
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

  RecipeHandlerPayload? _payload;
  double _progress = 0.0;
  int _index = 0;
  bool _chain = false;
  bool _notStateChangeOccured = false;

  RecipeProcessor(this._device) {
    lastStateChangeTime = DateTime.now();

    _stateChanges.listen((moduleResponse) {
      DateTime currentTime = DateTime.now();
      if (currentTime.difference(lastStateChangeTime) >=
          Duration(seconds: RecipeProcessor.IDLE_TIME)) {
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
          Duration(seconds: RecipeProcessor.IDLE_TIME)) {
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
          _payload!.task.status = Task.COMPLETED;
          var endTime = DateTime.now();
          int estimatedTimeCompletion =
              endTime.difference(taskStarted).inSeconds;

          _payload!.recipe.cookCount = _payload!.recipe.cookCount ?? 0 + 1;
          _payload!.recipe.estimatedTimeCompletion =
              estimatedTimeCompletion.toDouble();

          await recipeDataAccess.updateById(
              _payload!.recipe.id!, _payload!.recipe);
          await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
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
      } else if (message is KillIsolate) {
        // Isolate.kill(priority: Isolate.immediate);
      } else if (message is SendPort) {
        _sendPort = message;
        // print('_sendPort assigned');
      } else if (message is IngredientHandlerPayload) {
        final availableProcessor = ThreadPool.instance.pool.firstWhere(
            (processor) => (processor is TransporterProcessor),
            orElse: () => throw Exception('No transporter available in the pool'));
        await (availableProcessor as TransporterProcessor).process(message);
      }
    });

    _isolate = await Isolate.spawn(recipeIsolateEntryPoint, _receivePort.sendPort);
  }

  Future<void> process(HandlerPayload p) async {
    if (p is RecipeHandlerPayload) {
      _payload = p;

      int? duration = p.recipe.estimatedTimeCompletion?.toInt();

      for (var i = 0; i < p.operations.length; i++) {
        if (p.operations[i] is AdvancedOperation) {
          print('Porting new object');
          p.operations[i] =
              (await baseOperationDataAccess.getById(p.operations[i].id!))!;
        }
      }

      if (duration == null || duration == 0) {
        for (var i = 0; i < p.operations.length; i++) {
          if (p.operations[i] is AdvancedOperation) {
            p.operations[i] =
                (await baseOperationDataAccess.getById(p.operations[i].id!))!;
          }

          BaseOperation operation = p.operations[i];
          if (operation is TimedOperation) {
            TimedOperation op = (operation) as TimedOperation;
            duration = duration! + (op.duration ?? 0);
          }

          if (operation.operation == RepeatOperation.CODE) {
            RepeatOperation repeater = (operation as RepeatOperation);
            Iterable<BaseOperation> _repeatSequence = p.operations.getRange(
                (repeater.repeatIndex!) > 0 ? (repeater.repeatIndex! - 1) : 0,
                i);

            for (var j = 0; j < repeater.repeatCount!; j++) {
              print("REPEAT ${j + 1}");
              for (BaseOperation _operation in _repeatSequence) {
                if (_operation is TimedOperation) {
                  TimedOperation _op = (_operation) as TimedOperation;
                  duration = duration! + _op.duration!;
                }
              }
            }
          }
        }
        etaInSeconds = duration ?? 0 + 120;
      } else {
        etaInSeconds = duration;
      }

      _sendPort.send([_receivePort.sendPort, p, _device]);
    }
  }

  void updateStats(ModuleResponse moduleResponse) {
    _device = moduleResponse;
    _busy = _device.requestId != 'idle';
    _deviceStateChange.sink.add(moduleResponse);
  }

  String? getModuleName() {
    return moduleName();
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

  RecipeHandlerPayload? getPayload() {
    return _payload;
  }

  double getProgress() {
    return _progress;
  }

  int getIndexProgress() {
    return _index;
  }

  BaseOperation? getCurrentOperation() {
    if (_payload == null) {
      return null;
    }

    if (_payload!.operations.isEmpty) {
      print("Operation is empty");
      return null;
    }

    return _payload?.operations[_index];
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
    return _device.moduleName ?? 'unknown';
  }
}
