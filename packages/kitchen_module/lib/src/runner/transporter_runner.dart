import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:kitchen_module/kitchen_module.dart';

//read about isolate implementation in dart
Future<void> transporterIsolateEntryPoint(SendPort sendPort) async {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  await for (var message in receivePort) {
    if (message is List) {
      // event sender port to notify the user about anything
      final SendPort eventSenderPort = message[0];
      final IngredientHandlerPayload payload = message[1];
      final ModuleResponse _device = message[2];
      eventSenderPort.send("started");
      bool? available = await waitForTransporterIdle(payload, _device);
      eventSenderPort.send(TaskProgress(1));
      eventSenderPort.send("completed");
    }
  }
}

Future<bool?> waitForTransporterIdle(
    IngredientHandlerPayload payload, ModuleResponse server) async {
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

  var json = payload.toJson();
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
          var parsedJson = jsonDecode(result);
          ModuleResponse incomingStats;
          if (parsedJson['type'] == 'STIR_FRY_MODULE') {
            incomingStats = StirFryResponse(parsedJson);
          } else if (parsedJson['type'] == 'TRANSPORTER_MODULE') {
            incomingStats = TransporterResponse(parsedJson);
          } else {
            throw HandshakeException(
                "waitForTransporterIdle() Failed to handshake with incoming response with type, ${parsedJson['type']}");
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
