// udp_server.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';


enum ModuleType {
  STIR_FRY_MODULE,
  TRANSPORTER_MODULE
}

class DummyUdpServer {
  late RawDatagramSocket server;
  late String moduleName;
  final ModuleType moduleType;
  String status = 'idle';
  int previousCode = 100;
  double targetTemperature = 100.0;


  DummyUdpServer(String ipAddress, int port, this.moduleType) {
    var random = Random();
    int i = random.nextInt(10);
    moduleName = "Module $i";
    initServer(ipAddress, port);
  }

  Future<void> initServer(String ipAddress, int port) async {
    server = await RawDatagramSocket.bind(InternetAddress(ipAddress), port);

    // Listen for UDP datagrams
    server.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        // Receive the datagram
        Datagram? datagram = server.receive();
        if (datagram != null) {
          handleDatagram(datagram, ipAddress, port);
        }
      }
    });
  }

  void handleDatagram(Datagram datagram, String ipAddress, int port) {
    // Extract data and sender information from the received datagram
    String message = String.fromCharCodes(datagram.data);
    Map<String, dynamic> data = jsonDecode(message);
    if(data['operation']!=100){
      if(previousCode != data['operation']){
        status = data['request_id'];
        targetTemperature = data['target_temperature'];
        Future.delayed(
          Duration(seconds: 15),
              () {
            status = 'idle';
          },
        );
        previousCode = data['operation'];
      }
    }

    InternetAddress senderAddress = datagram.address;
    int senderPort = datagram.port;

    var random = Random();
    double randomDouble = (random.nextDouble() * (300.0 - 30.0)) + 30.0;

    var respond = {
      "ip": "$ipAddress",
      "port":port,
      "name": "$moduleName",
      "type" : "${moduleType == ModuleType.STIR_FRY_MODULE ? "STIR_FRY_MODULE": "TRANSPORTER_MODULE"}",
      "group" : "GROUP 1",
      "v5" : 5.1,
      "le" : "",
      "code" : "0",
      "rid": status,
      "mem": 0,
      "prog": 0,
      "ci": 0,
      "i_s": 0,
      "rmotor": 0,
      "tmotor": 9,
      "temp": randomDouble,
      "clt": 0,
      "ltm": 0,
      "mt": 0,
      "ttemp": targetTemperature ?? 0,
      "ovo": false,
      "wvo": false,
      "wjo": false
    };


    String responseMessage = jsonEncode(respond);
    List<int> responseBytes = responseMessage.codeUnits;
    server.send(responseBytes, senderAddress, senderPort);
  }

  void closeServer() {
    server.close();
  }
}
