import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/model/instruction.dart';
import 'package:kitchen_studio_10162023/model/recipe.dart';

Future recipeRunner(Recipe recipe, List<BaseOperation> operations,
    DeviceStats deviceStats) async {
  ReceivePort thisRecieverPort = ReceivePort();
  Isolate.spawn<SendPort>(runners, thisRecieverPort.sendPort);
  SendPort mikeSendPort = await thisRecieverPort.first;
  ReceivePort runnerRecieverPort = ReceivePort();
  mikeSendPort.send([recipe, operations, deviceStats, runnerRecieverPort.sendPort]);

  runnerRecieverPort.listen((message) {
    print("Runners'S RESPONSE: ==== $message");
  });
}

void runners(SendPort mySendPort) async {
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
      DeviceStats deviceStats = message[2];
      final SendPort thisRunnerSenderPort = message[3];

      RawDatagramSocket socket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889);
      socket.broadcastEnabled = true;
      int currentIndex = 0;

      socket.send(jsonEncode(operations[currentIndex].toJson()).codeUnits,
          InternetAddress(deviceStats.ipAddress!), deviceStats.port!);
      currentIndex = currentIndex + 1;

      socket.send(jsonData.codeUnits, InternetAddress(deviceStats.ipAddress!), 8888);


      while (currentIndex < operations.length){
        socket.send(jsonData.codeUnits, InternetAddress(deviceStats.ipAddress!), 8888);
        Datagram? dg = socket.receive();
        if (dg != null) {
          String result = String.fromCharCodes(dg.data);
          DeviceStats incomingStats = DeviceStats.fromJson(jsonDecode(result));

          if (incomingStats.ipAddress == deviceStats.ipAddress) {
            if (incomingStats.requestId == 'idle') {
              thisRunnerSenderPort.send("Running next queue");
              socket.send(
                  jsonEncode(operations[currentIndex].toJson()).codeUnits,
                  InternetAddress(deviceStats.ipAddress!),
                  deviceStats.port!);
              currentIndex = currentIndex + 1;
            } else {
              thisRunnerSenderPort.send("Completed");
            }
          }
        }
      }


      thisRunnerSenderPort.send("Completed");

    }
  }
}
