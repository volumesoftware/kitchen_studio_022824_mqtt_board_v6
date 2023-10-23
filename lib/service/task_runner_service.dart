import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:kitchen_studio_10162023/dao/recipe_data_access.dart';
import 'package:kitchen_studio_10162023/dao/task_data_access.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/model/instruction.dart';
import 'package:kitchen_studio_10162023/model/recipe.dart';
import 'package:kitchen_studio_10162023/model/task.dart';

abstract interface class TaskListener {
  void onEvent(String moduleName, dynamic message,
      {required bool busy,
      required DeviceStats deviceStats,
      required double progress});
}

class TaskProgress {
  final double _progress;

  TaskProgress(this._progress);

  double get progress => _progress;
}

class TaskPayload {
  final Recipe recipe;
  final List<BaseOperation> operations;
  final DeviceStats deviceStats;
  final Task task;

  TaskPayload(this.recipe, this.operations, this.deviceStats, this.task);
}

class TaskRunner {
  TaskDataAccess taskDataAccess = TaskDataAccess.instance;
  RecipeDataAccess recipeDataAccess = RecipeDataAccess.instance;

  DeviceStats _deviceStats;
  bool _busy = false;
  late SendPort _sendPort;
  final List<TaskListener> _eventListeners = [];
  final ReceivePort _eventPort = ReceivePort();
  TaskPayload? _payload;
  double _progress = 0.0;

  TaskRunner(this._deviceStats);

  void updateStats(DeviceStats deviceStats) {
    _deviceStats = deviceStats;
    _eventListeners.forEach((element) {
      element.onEvent(_deviceStats.moduleName!, 'Status update',
          busy: _busy, deviceStats: _deviceStats, progress: _progress);
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

  Future<void> initialize() async {
    ReceivePort receivePort = ReceivePort();
    Isolate.spawn<SendPort>(runner, receivePort.sendPort);
    _sendPort = await receivePort.first;
    _eventPort.listen((message) async {
      if (message == "completed") {
        _busy = false;
        _payload!.task.status = Task.COMPLETED;
        await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
        _payload = null;
      } else if (message == "started") {
        _busy = true;
        if (_payload != null) {
          _payload!.task.status = Task.STARTED;
          await taskDataAccess.updateById(_payload!.task.id!, _payload!.task);
        }
      } else if (message is TaskProgress) {
        _progress = message.progress;
      }
      _eventListeners.forEach((element) {
        element.onEvent(_deviceStats.moduleName!, message,
            busy: _busy, deviceStats: _deviceStats, progress: _progress);
      });
    });
  }

  void addListeners(TaskListener listener) {
    _eventListeners.add(listener);
  }

  void removeListeners(TaskListener listener) {
    _eventListeners.remove(listener);
  }

  Future<void> submitTask(TaskPayload p) async {
    _payload = p;

    if (!_busy) {
      print("a task submitted here but not busy");
      _eventListeners.forEach((element) {
        element.onEvent(_deviceStats.moduleName!, "Device is not busy",
            busy: _busy, progress: _progress, deviceStats: _deviceStats);
      });
      _sendPort.send([_eventPort.sendPort, p]);
    } else {
      print("a task submitted here but busy");
      _eventListeners.forEach((element) {
        element.onEvent(_deviceStats.moduleName!, "Device is busy",
            busy: _busy, deviceStats: _deviceStats, progress: _progress);
      });
    }
  }

  void stopTask() {}
}

Future<void> runner(SendPort sendPort) async {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);
  await for (var message in receivePort) {
    if (message is List) {
      final SendPort eventSenderPort = message[0];
      final TaskPayload payload = message[1];
      int totalProgress = payload.operations.length + 1;

      eventSenderPort.send("started");

      for (var i = 0; i < payload.operations.length; i++) {
        eventSenderPort.send(TaskProgress((i + 1) / totalProgress));
        BaseOperation operation = payload.operations[i];
        bool? available = await waitForArduino(operation, payload.deviceStats);
      }
      eventSenderPort.send(TaskProgress(1));
      // await waitForArduino(ZeroingOperation(), payload.deviceStats);
      eventSenderPort.send("completed");
    }
  }
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
