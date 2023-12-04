import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:kitchen_studio_10162023/dao/operation_data_access.dart';
import 'package:kitchen_studio_10162023/dao/recipe_data_access.dart';
import 'package:kitchen_studio_10162023/dao/task_data_access.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/model/instruction.dart';
import 'package:kitchen_studio_10162023/model/recipe.dart';
import 'package:kitchen_studio_10162023/model/task.dart';
import 'package:kitchen_studio_10162023/model/user_action_operation.dart';

abstract interface class TaskListener {
  void onEvent(String moduleName, dynamic message,
      {required bool busy,
      required DeviceStats deviceStats,
      required double progress,
      required int index,
      UserAction? userAction});

  void onError(ModuleError error);
}

class UserAction {
  final String? _title;
  final String? _message;
  final int? _currentIndex;

  UserAction(this._title, this._message, this._currentIndex);

  String? get title => _title;

  String? get message => _message;

  int? get currentIndex => _currentIndex;

  @override
  String toString() {
    return '{'
        '"title" : $title,'
        '"message" : $message,'
        '"currentIndex" : $currentIndex'
        '}';
  }
}

class ModuleError {
  final DeviceStats? deviceStats;
  final String? error;

  ModuleError({required this.error, required this.deviceStats});
}

class UserResponse {
  final bool? respond;

  UserResponse(this.respond);
}

class TaskProgress {
  final double _progress;

  TaskProgress(this._progress);

  double get progress => _progress;
}

class IndexProgress {
  final int _progress;

  IndexProgress(this._progress);

  int get progress => _progress;
}

class TaskPayload {
  final Recipe recipe;
  final List<BaseOperation> operations;
  final DeviceStats deviceStats;
  final Task task;

  TaskPayload(this.recipe, this.operations, this.deviceStats, this.task);
}

class TaskRunner {
  String? moduleName;

  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;
  BaseOperationDataAccess baseOperationDataAccess =
      BaseOperationDataAccess.instance;

  DeviceStats _deviceStats;
  bool _busy = false;
  late SendPort _sendPort;
  late List<SendPort> _userActionPort;
  final List<TaskListener> _eventListeners = [];

  ReceivePort _eventPort = ReceivePort();

  TaskPayload? _payload;
  double _progress = 0.0;
  int _index = 0;
  bool _chain = false;

  TaskRunner(this._deviceStats) {
    moduleName = _deviceStats.moduleName;
  }

  void updateStats(DeviceStats deviceStats) {
    _deviceStats = deviceStats;
    moduleName = _deviceStats.moduleName;

    _busy = _deviceStats.requestId != 'idle';

    _eventListeners.forEach((element) {
      element.onEvent(_deviceStats.moduleName!, 'Status update',
          busy: _busy,
          deviceStats: _deviceStats,
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
      element.onEvent(_deviceStats.moduleName!, 'Status update',
          busy: _busy,
          deviceStats: _deviceStats,
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
    return _deviceStats;
  }

  Future<void> playNotificationSound() async {
    AudioCache audioCache = AudioCache();
    // Replace 'notification_sound.mp3' with the path to your audio file
    const notificationSound = 'audio/attention.mp3';

    // Use the audio cache to play the notification sound
    await audioCache.play(notificationSound);
  }

  Future<void> initialize(int userActionSize) async {
    _eventPort = ReceivePort();
    ReceivePort receivePort = ReceivePort();
    Isolate.spawn<RunnerModel>(
        runner, RunnerModel(receivePort.sendPort, userActionSize));
    List<SendPort> __sendPorts = await receivePort.first;
    _sendPort = __sendPorts[0];
    _userActionPort = __sendPorts.getRange(1, __sendPorts.length).toList();

    _eventPort.listen((message) async {
      if (message == "completed") {
        _busy = false;
        _payload!.task.status = Task.COMPLETED;
        await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
        _payload = null;

        _eventListeners.forEach((element) {
          element.onEvent(_deviceStats.moduleName!, message,
              busy: _busy,
              deviceStats: _deviceStats,
              progress: _progress,
              index: _index);
        });

        if (_chain) {
          var tasks = await taskDataAccess.search('status = ? and name = ?',
              whereArgs: [Task.CREATED, _deviceStats.moduleName!]);
          if (tasks != null) {
            if (tasks.isNotEmpty) {
              var task = tasks.first;
              var recipe = await recipeDataAccess.getById(task.recipeId!);
              if (recipe != null) {
                var operations = await baseOperationDataAccess
                    .search('recipe_id = ?', whereArgs: [recipe.id!]);
                if (operations != null) {
                  await submitTask(
                      TaskPayload(recipe, operations, _deviceStats, task));
                }
              }
            }
          }
        } else {
          receivePort.close();
          _eventPort.close();
        }
      } else if (message == "started") {
        _busy = true;
        if (_payload != null) {
          _payload!.task.status = Task.STARTED;
          await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
        }
        _eventListeners.forEach((element) {
          element.onEvent(_deviceStats.moduleName!, message,
              busy: _busy,
              deviceStats: _deviceStats,
              progress: _progress,
              index: _index);
        });
      } else if (message is TaskProgress) {
        _progress = message.progress;
        _eventListeners.forEach((element) {
          element.onEvent(_deviceStats.moduleName!, message,
              busy: _busy,
              deviceStats: _deviceStats,
              progress: _progress,
              index: _index);
        });
      } else if (message is IndexProgress) {
        _index = message.progress;
        _eventListeners.forEach((element) {
          element.onEvent(_deviceStats.moduleName!, message,
              busy: _busy,
              deviceStats: _deviceStats,
              progress: _progress,
              index: _index);
        });
      } else if (message is UserAction) {
        print(message);
        _eventListeners.forEach((element) {
          element.onEvent(_deviceStats.moduleName!, message,
              busy: _busy,
              deviceStats: _deviceStats,
              progress: _progress,
              index: _index,
              userAction: message);
        });
      } else if (message is UserResponse) {
        print(message);
        _eventListeners.forEach((element) {
          element.onEvent(_deviceStats.moduleName!, message,
              busy: _busy,
              deviceStats: _deviceStats,
              progress: _progress,
              index: _index);
        });
      } else if (message is ModuleError) {
        _payload = null;
        _busy = false;
        _eventListeners.forEach((element) {
          element.onError(message);
        });
      }
    });
  }

  void addListeners(TaskListener listener) {
    _eventListeners.add(listener);
  }

  void removeListeners(TaskListener listener) {
    _eventListeners.remove(listener);
  }

  void submitUserRespond(bool? userRespond, int currentIndex) {
    print(_userActionPort.length);
    _userActionPort[currentIndex].send([userRespond]);
  }

  Future<void> submitTask(TaskPayload p) async {
    // final results = await Ping(p.deviceStats.ipAddress!, count: 1).stream.toList();
    // results.forEach((element) {
    //   if (element.summary?.received == 0) {
    //     _payload = null;
    //     _eventListeners.forEach((element) {
    //       element.onError(ModuleError(
    //           error: 'Module not connected', deviceStats: p.deviceStats));
    //     });
    //
    //     return;
    //   }
    // });

    // [PingResponse(seq:null, ip:192.168.43.168, ttl:128, time:1.0 ms), PingSummary(transmitted:1, received:1)] connected
    //[PingError(response:PingResponse(seq:null), error:requestTimedOut), PingSummary(transmitted:1, received:0), Errors: [requestTimedOut, unknown: Ping process exited with code: 1]]
    _payload = p;

    if (!_busy) {
      int userActionSize = 0;

      p.operations.forEach((element) {
        if (element is UserActionOperation) {
          userActionSize = userActionSize + 1;
        }
      });

      await initialize(userActionSize);
      print("a task submitted here but not busy");
      _eventListeners.forEach((element) {
        element.onEvent(_deviceStats.moduleName!, "Device is not busy",
            busy: _busy,
            progress: _progress,
            deviceStats: _deviceStats,
            index: _index);
      });
      _sendPort.send([_eventPort.sendPort, p]);
    } else {
      print("a task submitted here but busy");
      _eventListeners.forEach((element) {
        element.onEvent(_deviceStats.moduleName!, "Device is busy",
            busy: _busy,
            deviceStats: _deviceStats,
            progress: _progress,
            index: _index);
      });
    }
  }
}

class RunnerModel {
  final SendPort _sendPort;
  final int _totalUserAction;

  RunnerModel(this._sendPort, this._totalUserAction);

  SendPort get sendPort => _sendPort;

  int get totalUserAction => _totalUserAction;
}

Future<void> runner(RunnerModel initialPayload) async {
  ReceivePort receivePort = ReceivePort();
  List<SendPort> receivePorts = [receivePort.sendPort];
  List<ReceivePort> userReceivePorts = [];
  for (var i = 0; i < initialPayload.totalUserAction; i++) {
    ReceivePort userReceivePort = ReceivePort();
    userReceivePorts.add(userReceivePort);
  }
  userReceivePorts.forEach((element) {
    receivePorts.add(element.sendPort);
  });

  initialPayload.sendPort.send(receivePorts);

  await for (var message in receivePort) {
    if (message is List) {
      final SendPort eventSenderPort = message[0];
      final TaskPayload payload = message[1];
      int totalProgress = payload.operations.length + 1;
      eventSenderPort.send("started");

      int userRequestIndex = 0;
      // Stopwatch stopwatch = new Stopwatch()..start();
      for (var i = 0; i < payload.operations.length; i++) {
        // final results = await Ping(payload.deviceStats.ipAddress!, count: 1)
        //     .stream
        //     .toList();
        // results.forEach((element) {
        //   if (element.summary?.received == 0) {
        //     eventSenderPort.send(ModuleError(
        //         error: "Module Not Connected",
        //         deviceStats: payload.deviceStats));
        //     return;
        //   }
        // });

        BaseOperation operation = payload.operations[i];
        bool? isIdle = await clearIdle(operation, payload.deviceStats);
        eventSenderPort.send(TaskProgress((i + 1) / totalProgress));
        eventSenderPort.send(IndexProgress(i));
        if (operation.operation == UserActionOperation.CODE) {
          eventSenderPort.send(UserAction("", "", operation.currentIndex));
        }
        bool? available = await waitForIdle(operation, payload.deviceStats);
      }

      bool? available = await waitForIdle(
          UserActionOperation(
              message: "",
              title: "",
              currentIndex: 0,
              targetTemperature: 28,
              isClosing: true),
          payload.deviceStats);

      eventSenderPort.send(TaskProgress(1));
      // await waitForArduino(ZeroingOperation(), payload.deviceStats);
      eventSenderPort.send("completed");
    }
  }
}

Future<bool?> waitForUserAction(BaseOperation operation, DeviceStats server,
    ReceivePort userReceivePort) async {
  ReceivePort _userReceivePort = userReceivePort;
  stderr.writeln("waiting for user action");
  Completer<bool?> completer = Completer();
  var sub = _userReceivePort.listen(
    (message) {
      if (message is List) {
        stderr.writeln('User Respond ${message[0]}');
        completer.complete(message[0]);
      }
    },
  );
  return completer.future;
}

Future<bool?> waitForIdle(BaseOperation operation, DeviceStats server) async {

  if (operation.operation == UserActionOperation.CODE) {
    // playNotificationSound();
  }

  int maX = 9000;
  int miN = 8000;
  int randomPort = Random().nextInt(maX - miN) + miN;
  RawDatagramSocket? socket =
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, randomPort);

  String jsonData = '{"operation":100}';
  Timer timer = Timer.periodic(
    Duration(seconds: 3),
    (timer) {
      socket.send(
          jsonData.codeUnits, InternetAddress(server.ipAddress!), server.port!);
    },
  );

  var json = operation.toJson();
  socket.send(jsonEncode(json).codeUnits, InternetAddress(server.ipAddress!),
      server.port!);

  Completer<bool?> completer = Completer();
  // Listen for incoming data and complete the Future when data is received
  var sub = socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      Datagram? datagram = socket.receive();
      if (datagram != null) {
        try {
          String result = String.fromCharCodes(datagram.data);
          DeviceStats incomingStats = DeviceStats.fromJson(jsonDecode(result));
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

Future<bool?> clearIdle(BaseOperation operation, DeviceStats server) async {
  int maX = 5000;
  int miN = 4000;
  int randomPort = Random().nextInt(maX - miN) + miN;

  RawDatagramSocket? socket =
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, randomPort);

  String jsonData = '{"operation":100}';
  Timer timer = Timer.periodic(
    Duration(seconds: 3),
    (timer) {
      socket.send(
          jsonData.codeUnits, InternetAddress(server.ipAddress!), server.port!);
    },
  );

  socket.send(jsonEncode(operation.toJson()).codeUnits,
      InternetAddress(server.ipAddress!), server.port!);

  Completer<bool?> completer = Completer();
  // Listen for incoming data and complete the Future when data is received
  var sub = socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      Datagram? datagram = socket.receive();
      if (datagram != null) {
        try {
          String result = String.fromCharCodes(datagram.data);
          DeviceStats incomingStats = DeviceStats.fromJson(jsonDecode(result));
          if (incomingStats.requestId != 'idle') {
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
