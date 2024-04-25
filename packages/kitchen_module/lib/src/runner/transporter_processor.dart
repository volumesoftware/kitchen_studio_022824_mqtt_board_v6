import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:kitchen_module/kitchen_module.dart';

class TransporterProcessor implements KitchenToolProcessor {
  bool _isInitialized = false;
  bool _busy = false;
  late DateTime lastStateChangeTime;
  late DateTime taskStarted;
  int etaInSeconds = 0;
  Timer? timer;
  static int IDLE_TIME = 3;

  Set<String?> lastErrors = Set();
  final List<Map<String, dynamic>> buffer = [];
  final List<Map<String, dynamic>> doingBuffer = [];
  bool isProcessing = false;

  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;
  BaseOperationDataAccess baseOperationDataAccess = BaseOperationDataAccess.instance;

  StreamController<ModuleResponse> _deviceStateChange = StreamController<ModuleResponse>.broadcast();
  StreamController<ModuleResponse> _heartBeatChange = StreamController<ModuleResponse>.broadcast();
  StreamController<Map<String, dynamic>> _taskStreamController = StreamController<Map<String, dynamic>>.broadcast();

  //listen to the state change of the thread pool
  Stream<ModuleResponse> get _stateChanges => _deviceStateChange.stream;

  Stream<ModuleResponse> get hearBeat => _heartBeatChange.stream;

  Stream<Map<String, dynamic>> get taskStream => _taskStreamController.stream;

  ModuleResponse _device;
  late Isolate _isolate;
  late SendPort _sendPort;
  late ReceivePort _receivePort;

  HandlerPayload? _payload;
  double _progress = 0.0;
  int _index = 0;
  bool _chain = false;
  bool _notStateChangeOccured = false;
  Completer<bool?>? singleCompleter;

  TransporterProcessor(this._device) {
    lastStateChangeTime = DateTime.now();
    _stateChanges.listen((moduleResponse) {
      DateTime currentTime = DateTime.now();
      if (currentTime.difference(lastStateChangeTime) >= Duration(seconds: TransporterProcessor.IDLE_TIME)) {
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
      if (currentTime.difference(lastStateChangeTime) >= Duration(seconds: TransporterProcessor.IDLE_TIME)) {
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
  bool get noStateChange => _notStateChangeOccured;

  void _initIsolate() async {
    _receivePort = ReceivePort();
    _receivePort.listen((message) async {
      print(message);
      if (message is String) {
        if (message == "completed") {
          final doing = doingBuffer.removeLast();
          _busy = false;
          _payload = null;
          singleCompleter?.complete(true);
          _taskStreamController.sink.add(doing);
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
      } else if (message is StirFryResponse) {
        RecipeProcessor? requester = ThreadPool.instance.pool.firstWhere(
            (processor) => ((processor is RecipeProcessor) && (processor.moduleName() == message.moduleName)),
            orElse: () => throw Exception('No Requester available in the pool')) as RecipeProcessor?;
        if (requester != null) {
          requester.notifyIngredientSlotFilled();
          handleBuffers();
          singleCompleter = null;
        } else {
          throw Exception('No Requester available in the pool !');
        }
      } else if (message is TaskProgress) {
        _progress = message.progress;
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

    _isolate = await Isolate.spawn(transporterIsolateEntryPoint, _receivePort.sendPort);
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

  Future<void> process(HandlerPayload p) async {
    // _payload = p;
    // _sendPort.send([_receivePort.sendPort, p, _device]);
  }

  Future<void> handleRequest(Map<String, dynamic> toSend) async {
    buffer.add(toSend);
    _taskStreamController.sink.add(toSend);
    if (!isProcessing) {
      handleBuffers();
    }
  }

  void handleBuffers() {
    isProcessing = true;
    singleCompleter = Completer();
    if (buffer.isNotEmpty) {
      final currentTask = buffer.removeAt(0);
      var requester = currentTask["requester"];
      var flag = currentTask["flag"];
      doingBuffer.add(currentTask);
      _sendPort.send([_receivePort.sendPort, currentTask, _device, flag, requester]);
    }
    isProcessing = false;
  }

  Future<bool?> waitForTaskCompletion() async {
    Completer<bool?> completer = Completer();
    int maX = 9000;
    int miN = 8000;
    int randomPort = Random().nextInt(maX - miN) + miN;
    RawDatagramSocket? socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, randomPort);

    String jsonData = '{"operation":100}';
    Timer timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        socket.send(jsonData.codeUnits, InternetAddress(getModuleResponse().ipAddress!), getModuleResponse().port!);
      },
    );

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
              throw HandshakeException(
                  " TransporterRunner.dart waitForTransporterIdle() Failed to handshake with incoming response with type, ${parsedJson['type']}");
            }
            if (incomingStats.requestId == 'idle') {
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
  String toString() {
    return "${_device.type} ${moduleName()}";
  }

  @override
  String moduleName() {
    return _device.moduleName ?? "Unknown";
  }
}
