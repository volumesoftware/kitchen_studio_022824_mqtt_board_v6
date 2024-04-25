import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/service/json_processor.dart';

class RecipeProcessor implements KitchenToolProcessor {
  bool _isInitialized = false;
  bool _busy = false;
  late DateTime lastStateChangeTime;
  late DateTime taskStarted;
  int etaInSeconds = 0;
  Timer? timer;
  static const int IDLE_TIME = 10;
  TaskProgress? _currentProgress;

  Set<String?> lastErrors = {};

  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;
  BaseOperationDataAccess baseOperationDataAccess = BaseOperationDataAccess.instance;
  final StreamController<ModuleResponse> _deviceStateChange = StreamController<ModuleResponse>.broadcast();
  final StreamController<ModuleResponse> _heartBeatChange = StreamController<ModuleResponse>.broadcast();

  ModuleResponse _device;
  late Isolate _isolate;
  late SendPort _sendPort;
  late SendPort _ingredientFilledPort;
  late ReceivePort _receivePort;

  RecipeHandlerPayload? _payload;
  bool _chain = false;
  bool _notStateChangeOccured = false;

  RecipeProcessor(this._device) {
    lastStateChangeTime = DateTime.now();

    _stateChanges.listen((moduleResponse) {
      DateTime currentTime = DateTime.now();
      if (currentTime.difference(lastStateChangeTime) >= Duration(seconds: RecipeProcessor.IDLE_TIME)) {
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

    Timer.periodic(const Duration(seconds: 2), (_) {
      DateTime currentTime = DateTime.now();
      if (currentTime.difference(lastStateChangeTime) >= Duration(seconds: RecipeProcessor.IDLE_TIME)) {
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
          int estimatedTimeCompletion = endTime.difference(taskStarted).inSeconds;
          _payload!.recipe.cookCount = _payload!.recipe.cookCount ?? 0 + 1;
          _payload!.recipe.estimatedTimeCompletion = estimatedTimeCompletion.toDouble();
          await recipeDataAccess.updateById(_payload!.recipe.id!, _payload!.recipe);
          await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
          _payload = null;
        } else if (message == "started") {
          _busy = true;
          if (_payload != null) {
            taskStarted = DateTime.now();
            const oneSec = Duration(seconds: 1);
            timer = Timer.periodic(
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
        _currentProgress = message;
      } else if (message is UserAction) {
      } else if (message is UserResponse) {
      } else if (message is Exception) {
        _payload = null;
        _busy = false;
      } else if (message is KillIsolate) {
        // Isolate.kill(priority: Isolate.immediate);
      } else if (message is SendPorts) {
        _sendPort = message.taskSendPort;
        _ingredientFilledPort = message.ingredientSendPort;
        // print('_sendPort assigned');
      } else if (message is Map<String, dynamic>) {
        if (message["operation"] == InstructionCode.requestIngredient) {
          final availableProcessor = ThreadPool.instance.pool
              .firstWhere((processor) => (processor is TransporterProcessor), orElse: () => throw Exception('No transporter available in the pool'));
          message["requester"] = getModuleResponse();
          message["flag"] = getModuleResponse().moduleName;

          (availableProcessor as TransporterProcessor).handleRequest(message);
        }
      }
    });
    _isolate = await Isolate.spawn(recipeV6IsolateEntryPoint, _receivePort.sendPort);
  }

  @override
  Future<void> process(HandlerPayload p) async {
    if (p is RecipeHandlerPayload) {
      _payload = p;
      _payload!.instructions = replaceRepeat(p.instructions); // flatten the instructions
      _sendPort.send([_receivePort.sendPort, p, _device]);
    }
  }

  void notifyIngredientSlotFilled() {
    _ingredientFilledPort.send(getModuleResponse());
  }

  Future<bool?> sendAction(Map<String, dynamic> operation) async {
    int maX = 9000;
    int miN = 8000;
    int randomPort = Random().nextInt(maX - miN) + miN;
    RawDatagramSocket? socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, randomPort);

    String jsonData = '{"operation":100}';
    Timer timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        socket.send(jsonData.codeUnits, InternetAddress(getModuleResponse().ipAddress!), getModuleResponse().port!);
      },
    );

    socket.send(jsonEncode(operation).codeUnits, InternetAddress(getModuleResponse().ipAddress!), getModuleResponse().port!);

    Completer<bool?> completer = Completer();
    // Listen for incoming data and complete the Future when data is received
    var sub = socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = socket.receive();
        if (datagram != null) {
          try {
            String result = String.fromCharCodes(datagram.data);
            var parsedJson = jsonDecode(result);
            ModuleResponse incomingStats;
            if (parsedJson['type'] == 'STIR_FRY_MODULE' || parsedJson['type'] == 'STIR FRY MODULE') {
              incomingStats = StirFryResponse(parsedJson);
            } else if (parsedJson['type'] == 'TRANSPORTER_MODULE' || parsedJson['type'] == 'TRANSPORTER MODULE') {
              incomingStats = TransporterResponse(parsedJson);
            } else {
              throw HandshakeException("RecipeRunner.dart waitForIdle() Failed to handshake with incoming response with type, ${parsedJson['type']}");
            }
            if ((incomingStats.requestId == 'idle') && (incomingStats.moduleName == getModuleResponse().moduleName)) {
              print("arduinos ${incomingStats.requestId}");
              socket.close();
              timer.cancel();
              completer.complete(true);
            }
          } catch (e) {
            print(e);
          }
        }
      }
    });
    return completer.future;
  }

  @override
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

  @override
  bool isBusy() {
    return _busy;
  }

  RecipeHandlerPayload? getPayload() {
    return _payload;
  }

  List<Map<String, dynamic>> getFlattenedInstructions() {
    return getPayload()?.instructions ?? [];
  }

  int getInstructionsLength() {
    return _payload?.instructions.length ?? 0;
  }

  TaskProgress? getTaskProgress() {
    return _currentProgress;
  }

  @override
  ModuleResponse getModuleResponse() {
    return _device;
  }

  @override
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
