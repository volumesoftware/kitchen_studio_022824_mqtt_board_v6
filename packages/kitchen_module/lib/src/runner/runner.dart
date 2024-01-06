import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:database_service/database_service.dart';

Future<void> recipeIsolateEntryPoint(SendPort sendPort) async {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  await for (var message in receivePort) {
    if (message is List) {
      final SendPort eventSenderPort = message[0];
      final TaskPayload payload = message[1];
      final DeviceStats _device = message[2];
      int totalProgress = payload.operations.length + 1;
      eventSenderPort.send("started");
      List<BaseOperation> operations = payload.operations;

      for (var i = 0; i < operations.length; i++) {
        BaseOperation operation = operations[i];

        eventSenderPort.send(TaskProgress((i + 1) / totalProgress));
        eventSenderPort.send(IndexProgress(operation.currentIndex!));

        if (operation.operation == UserActionOperation.CODE) {
          eventSenderPort.send(UserAction("", "", operation.currentIndex));
        }
        else if(operation.operation == AdvancedOperation.CODE){
          AdvancedOperation advancedOperation = (operation as AdvancedOperation);
          if(advancedOperation.requireUserPermission!){
            eventSenderPort.send(UserAction("", "", operation.currentIndex));
          }
          bool? available = await waitForIdle(operation, _device);
        }
        else if (operation.operation == RepeatOperation.CODE) {
          RepeatOperation repeater = (operation as RepeatOperation);
          Iterable<BaseOperation> _repeatSequence =
              operations.getRange((repeater.repeatIndex!) > 0 ? (repeater.repeatIndex! - 1) : 0, i);

          for (var j = 0; j < repeater.repeatCount!; j++) {
            print("REPEAT ${j + 1}");
            for (BaseOperation _operation in _repeatSequence) {
              print("REPEAT ${_operation.toJson()}");
              eventSenderPort.send(IndexProgress(_operation.currentIndex!));
              await waitForIdle(_operation, _device);
            }
          }
        } else {
          bool? available = await waitForIdle(operation, _device);
        }
      }

      bool? available = await waitForIdle(
          PumpWaterOperation(
              currentIndex: 0,
              duration: 0,
              targetTemperature: 28),
          _device);
      eventSenderPort.send(TaskProgress(1));
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

  var json = (operation is AdvancedOperation) ? operation.toAdvancedJson() :operation.toJson();
  print("sending $json");
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
