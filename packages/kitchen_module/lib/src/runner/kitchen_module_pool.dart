import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:kitchen_module/kitchen_module.dart';

class KitchenModulePool  {
  // Creating geek isolate
  Isolate? pingHandler;

  KitchenModulePool._privateConstructor() {
    initialize(dummy: false);
  }

  static final KitchenModulePool _instance = KitchenModulePool._privateConstructor();

  static KitchenModulePool get instance => _instance;

  final Map<String, ModuleResponse> _deviceMap = {};

  //store the
  final StreamController<Map<String, ModuleResponse>> _stateChangesController = StreamController<Map<String, ModuleResponse>>.broadcast();

  //listen to the state change of the devices
  Stream<Map<String, ModuleResponse>> get stateChanges => _stateChangesController.stream;

  //get device map
  Map<String, ModuleResponse> get devices => Map<String, ModuleResponse>.from(_deviceMap);

  Future<void> ping(SendPort sendPort) async {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (var message in receivePort) {
      if (message is SendPort) {
        final SendPort eventSenderPort = message;
        RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8899);
        socket.broadcastEnabled = true;
        socket.listen((event) {
          Datagram? dg = socket.receive();
          if (dg != null) {
            final String result = String.fromCharCodes(dg.data);
            eventSenderPort.send(dg);
          }
        });

        String jsonData = '{"operation":100}';
        Timer.periodic(
          const Duration(seconds: 8),
              (timer) async {
            socket.send(jsonData.codeUnits, InternetAddress("192.168.43.255"), 8888);
          },
        );
      }
    }
  }

  Future<void> startPing() async {
    ReceivePort pingReceive = ReceivePort();
    SendPort? sendPort;
    pingHandler = await Isolate.spawn(ping, pingReceive.sendPort);
    pingReceive.listen((message) {
      if (message is SendPort) {
        sendPort = message;
        sendPort?.send(pingReceive.sendPort);
      }else if(message is Datagram){
        udpData(message);
      }
    });
  }

  void stopPing() {
    if (pingHandler != null) {
      pingHandler?.kill(priority: Isolate.immediate);
      pingHandler = null;
    }
  }

  void initialize({required bool dummy}) async {
    await startPing();
  }

  Future<void> udpData(Datagram dg) async {
    try {
      final String result = String.fromCharCodes(dg.data);
      final parsedJson = jsonDecode(result);
      ModuleResponse? moduleResponse;

        if (parsedJson['type'] == 'STIR_FRY_MODULE' || parsedJson['type'] == 'STIR FRY MODULE') {
        moduleResponse = StirFryResponse(parsedJson);
      } else if (parsedJson['type'] == 'TRANSPORTER_MODULE' || parsedJson['type'] == 'TRANSPORTER MODULE') {
        moduleResponse = TransporterResponse(parsedJson);
      } else {
        throw HandshakeException("Runner.dart Failed to handshake with incoming response with type, ${parsedJson['type']}");
      }

      _deviceMap[moduleResponse.ipAddress!] = moduleResponse;
      _stateChangesController.sink.add(Map<String, ModuleResponse>.from(_deviceMap));
    } catch (e) {
      print(e);
    }
  }

  void dispose() {
    _stateChangesController.close();
  }
}
