import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
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

  final ReceivePort _eventPort = ReceivePort();

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

  Future<void> initialize(int userActionSize) async {
    ReceivePort receivePort = ReceivePort();
    Isolate.spawn<RunnerModel>(runner, RunnerModel(receivePort.sendPort, userActionSize));
    List<SendPort> __sendPorts = await receivePort.first;
    print("Send Port Size ${__sendPorts.length}");
    _sendPort = __sendPorts[0];
    print("Send Port Size ${__sendPorts.length}");
    _userActionPort = __sendPorts.getRange(1, __sendPorts.length).toList();
    print("User Action Port Size ${_userActionPort.length}");

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
          var tasks = await taskDataAccess.search(
              'status = ? and module_name = ?',
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
        }else{
          receivePort.close();
          _eventPort.close();
        }
      }

      else if (message == "started") {
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
      }else if (message is UserResponse) {
        print(message);
        _eventListeners.forEach((element) {
          element.onEvent(_deviceStats.moduleName!, message,
              busy: _busy,
              deviceStats: _deviceStats,
              progress: _progress,
              index: _index);
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


    _payload = p;

    if (!_busy) {

      int userActionSize = 0;

      p.operations.forEach((element) {
        if(element is UserActionOperation){
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
  List<SendPort> receivePorts  = [receivePort.sendPort] ;
  List<ReceivePort> userReceivePorts = [];
  for(var i = 0; i < initialPayload.totalUserAction; i++){
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

      for (var i = 0; i < payload.operations.length; i++) {
        eventSenderPort.send(TaskProgress((i + 1) / totalProgress));
        eventSenderPort.send(IndexProgress(i));
        BaseOperation operation = payload.operations[i];
        if (operation is UserActionOperation) {
          eventSenderPort.send(UserAction(operation.title, operation.message, userRequestIndex));
          bool? userAction = await waitForUserAction(operation, payload.deviceStats, userReceivePorts[userRequestIndex]);
          eventSenderPort.send(UserResponse(userAction));
          userRequestIndex++;
        } else {
          bool? available = await waitForArduino(operation, payload.deviceStats);
        }
      }
      eventSenderPort.send(TaskProgress(1));
      // await waitForArduino(ZeroingOperation(), payload.deviceStats);
      eventSenderPort.send("completed");
    }
  }
}

Future<bool?> waitForUserAction(BaseOperation operation, DeviceStats server, ReceivePort userReceivePort) async {
  ReceivePort _userReceivePort = userReceivePort;
  stderr.writeln("waiting for user action");
  Completer<bool?> completer = Completer();
  var sub = _userReceivePort.listen((message) {
    if(message is List){
      stderr.writeln('User Respond ${message[0]}');
      completer.complete(message[0]);
    }
  },);
  return completer.future;
}



Future<bool?> waitForArduino(
    BaseOperation operation, DeviceStats server) async {
  RawDatagramSocket? socket =
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8882);

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
        String result = String.fromCharCodes(datagram.data);
        DeviceStats incomingStats = DeviceStats.fromJson(jsonDecode(result));
        if (incomingStats.requestId == 'idle') {
          completer.complete(true);
          socket.close();
        }
      }
    }
  });
  return completer.future;
}
