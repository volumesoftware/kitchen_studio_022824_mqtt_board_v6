import 'dart:io';
import 'dart:isolate';

void scanDeviceOne(SendPort mySendPort) async {
  print("Scan Once");

  /// Set up a receiver port for Mike
  ReceivePort mainReceivePort = ReceivePort();

  /// Send Mike receivePort sendPort via mySendPort
  mySendPort.send(mainReceivePort.sendPort);

  /// Listen to messages sent to Mike's receive port
  await for (var message in mainReceivePort) {
    if (message is List) {
      final String ipAddress = message[0] as String;
      final SendPort mikeResponseSendPort = message[1] as SendPort;

      String jsonData = '{"operation":100}';
      RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889)
          .then((RawDatagramSocket udpSocket) {
        udpSocket.broadcastEnabled = true;
        udpSocket.send(jsonData.codeUnits, InternetAddress(ipAddress), 8888);
        udpSocket.listen((e) {
          Datagram? dg = udpSocket.receive();
          if (dg != null) {
            String result = String.fromCharCodes(dg.data);
            mikeResponseSendPort.send('${result}');
          }
          udpSocket.close();
        });
      });
    }
  }
}
