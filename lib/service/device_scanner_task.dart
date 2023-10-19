import 'dart:io';
import 'dart:isolate';

Future deviceScanner(String address) async {
  ReceivePort mainReciever = ReceivePort();
  Isolate.spawn<SendPort>(scanDeviceOne, mainReciever.sendPort);
  SendPort mainSendPort = await mainReciever.first;
  ReceivePort mainResponseReceivePort = ReceivePort();
  mainSendPort.send([address, mainResponseReceivePort.sendPort]);
  final mikeResponse = await mainResponseReceivePort.first;
  print("MIKE'S RESPONSE: ==== $mikeResponse");
}

void scanDeviceOne(SendPort mySendPort) async {
  /// Set up a receiver port for Mike
  ReceivePort mainReceivePort = ReceivePort();

  /// Send Mike receivePort sendPort via mySendPort
  mySendPort.send(mainReceivePort.sendPort);

  /// Listen to messages sent to Mike's receive port
  await for (var message in mainReceivePort) {
    if (message is List) {
      final String ipAddress = message[0] as String;
      final SendPort mikeResponseSendPort = message[1] as SendPort;

      String jsonData =
          '{"operation":213,"cycle":2,"interval":300,"target_temperature":19}';
      RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889)
          .then((RawDatagramSocket udpSocket) {
        udpSocket.broadcastEnabled = true;
        udpSocket.send(jsonData.codeUnits, InternetAddress(ipAddress), 8888);
        udpSocket.listen((e) {
          print(e.toString());
          Datagram? dg = udpSocket.receive();
          if (dg != null) {
            String result = String.fromCharCodes(dg.data);
            print("received ${result}");
            mikeResponseSendPort.send('${result}');
          }
        });
      });
    }
  }
}
