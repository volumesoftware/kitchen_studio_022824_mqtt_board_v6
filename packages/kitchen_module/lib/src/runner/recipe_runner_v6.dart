import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:database_service/database_service.dart';

class InstructionCode {
  static const int repeat = 1;
  static const int inductionControl = 2;
  static const int timeout = 3;
  static const int dispense = 4;
  static const int flip = 5;
  static const int stir = 6;
  static const int tilt = 7;
  static const int abTilt = 8;
  static const int abcTilt = 9;
  static const int abcdTilt = 10;
  static const int infiniteRotate = 11;
  static const int rotate = 12;
  static const int abRotate = 13;
  static const int abcRotate = 14;
  static const int abcdRotate = 15;
  static const int pumpOil = 16;
  static const int pumpWater = 17;
  static const int userAction = 18;
  static const int wash = 19;
  static const int commitIngredient = 20;
  static const int requestIngredient = 21;
  static const int primeOil = 216;
  static const int primeWater = 217;
  static const int zeroing = 199;
}

class SendPorts {
  final SendPort taskSendPort;
  final SendPort ingredientSendPort;

  SendPorts(this.taskSendPort, this.ingredientSendPort);
}

//read about isolate implementation in dart
Future<void> recipeV6IsolateEntryPoint(SendPort sendPort) async {
  final receivePort = ReceivePort();
  final receivePort2 = ReceivePort();
  sendPort.send(SendPorts(receivePort.sendPort, receivePort2.sendPort));

  receivePort2.listen((message) async {
    if (message is ModuleResponse) {
      Map<String, dynamic> toSend = {"operation": 218, "request_id": "ingredientFilled"};
      print('receivePort2 $toSend');
      bool? available = await sendAndWaitForIdleV6(toSend, message);
    }
  });

  await for (var message in receivePort) {
    if (message is List) {
      final SendPort eventSenderPort = message[0];

      final RecipeHandlerPayload payload = message[1];
      final ModuleResponse device = message[2];
      List<Map<String, dynamic>> instructions = payload.instructions;
      int totalProgress = instructions.length;
      int currentIndex = 0;
      eventSenderPort.send("started");

      for (var obj in instructions) {
        eventSenderPort.send(TaskProgress(currentIndex / totalProgress, obj, currentIndex));
        if (obj["operation"] == InstructionCode.userAction) {
          eventSenderPort.send(UserAction(obj["title"], obj["message"], currentIndex));
          bool? available = await sendAndWaitForIdleV6(obj, device);
        } else if (obj["operation"] == InstructionCode.requestIngredient) {
          obj["request_title"] = "${obj["request_id"]}";
          obj["requester_name"] = "${device.moduleName}";
          obj["ingredient_type"] = obj["ingredient"]["ingredient_type"];
          obj["coordinate_x"] = obj["ingredient"]["coordinate_x"];
          obj["coordinate_r"] = (device as StirFryResponse).xCoordinate;
          eventSenderPort.send(obj);
          bool? available = await sendAndWaitForIdleV6(obj, device);
        } else {
          // sending code apart from user action and repeat
          bool? available = await sendAndWaitForIdleV6(obj, device);
        }
        currentIndex++;
      }

      // off the inductions
      bool? available = await sendAndWaitForIdleV6({"code": 2, "temperature": 0, "induction_power": 0}, device);
      eventSenderPort.send(TaskProgress(1, {}, 0));
      eventSenderPort.send("completed");
    }
  }
}

Future<bool?> sendAndWaitForIdleV6(Map<String, dynamic> operation, ModuleResponse server) async {
  int maX = 9000;
  int miN = 8000;
  int randomPort = Random().nextInt(maX - miN) + miN;
  RawDatagramSocket? socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, randomPort);

  String jsonData = '{"operation":100}';
  Timer timer = Timer.periodic(
    const Duration(seconds: 3),
    (timer) {
      socket.send(jsonData.codeUnits, InternetAddress(server.ipAddress!), server.port!);
    },
  );

  socket.send(jsonEncode(operation).codeUnits, InternetAddress(server.ipAddress!), server.port!);

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
          if ((incomingStats.requestId == 'idle') && (incomingStats.moduleName == server.moduleName)) {
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
