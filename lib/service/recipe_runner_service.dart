import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/model/instruction.dart';
import 'package:kitchen_studio_10162023/model/recipe.dart';
import 'package:kitchen_studio_10162023/model/zeroing_operation.dart';

Future recipeRunner(Recipe recipe, List<BaseOperation> operations,
    DeviceStats deviceStats) async {
  ReceivePort thisRecieverPort = ReceivePort();
  Isolate.spawn<SendPort>(runners, thisRecieverPort.sendPort);
  SendPort mikeSendPort = await thisRecieverPort.first;

  ReceivePort runnerRecieverPort = ReceivePort();
  mikeSendPort
      .send([recipe, operations, deviceStats, runnerRecieverPort.sendPort]);

  runnerRecieverPort.listen((message) {
    print("Runners'S RESPONSE: ==== $message");
  });
}

void runners(SendPort mySendPort) async {
  Timer? timer;
  String jsonData = '{"operation":100}';

  /// Set up a receiver port for Mike
  ReceivePort thisRunnerPort = ReceivePort();

  /// Send Mike receivePort sendPort via mySendPort
  mySendPort.send(thisRunnerPort.sendPort);

  /// Listen to messages sent to Mike's receive port
  await for (var message in thisRunnerPort) {
    if (message is List) {
      Recipe recipe = message[0];
      List<BaseOperation> operations = message[1];
      DeviceStats server = message[2];
      final SendPort thisRunnerSenderPort = message[3];

      await waitUntilUnitIsFree(ZeroingOperation(), server);
      for (BaseOperation operation in operations) {
        bool? available = await waitUntilUnitIsFree(operation, server);
        if (available != null) {
          thisRunnerSenderPort.send(available);
        }
      }
      await waitUntilUnitIsFree(ZeroingOperation(), server);
    }
  }
}

Future<bool?> waitUntilUnitIsFree(
    BaseOperation operation, DeviceStats server) async {
  RawDatagramSocket? socket =
      await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889);

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
