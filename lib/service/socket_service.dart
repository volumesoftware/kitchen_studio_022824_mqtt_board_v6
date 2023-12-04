// import 'dart:async';
// import 'dart:io';
//
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// abstract interface class ServerListener {
//   void onConnected(ServerSocket? serverSocket);
// }
//
// class SocketService {
//   ServerSocket? serverSocket;
//
//   SocketService._privateConstructor();
//
//   ServerListener? serverListener;
//
//   static final SocketService instance = SocketService._privateConstructor();
//
//   Future<Socket?> initialize(ServerListener serverListener) {
//     this.serverListener = serverListener;
//    return _runServer();
//   }
//
//   // Future<String?> _gettingIP() async {
//   //   await Permission.location.request();
//   //   final info = NetworkInfo();
//   //   var hostAddress = await info.getWifiIP();
//   //   return hostAddress;
//   // }
//
//   Future<Socket?> _runServer() async {
//     // Completer<Socket> socketCompleter = Completer();
//     // _gettingIP().then((value) async {
//     //   if (value != null) {
//     //     serverSocket = await ServerSocket.bind(
//     //         value, 8888); // Replace with your IP and desired port
//     //     if (serverSocket != null) {
//     //       serverListener?.onConnected(serverSocket);
//     //       print(
//     //           'Server running on: ${serverSocket?.address}:${serverSocket?.port}');
//     //       await for (Socket socket in serverSocket!) {
//     //         // handleConnection(socket);
//     //         socketCompleter.complete(socket);
//     //       }
//     //     }
//     //   }
//     // });
//     // return socketCompleter.future;
//   }
//
//   void _handleConnection(Socket socket) {
//     print('handling connection');
//     socket.listen((List<int> data) {
//       String receivedData = String.fromCharCodes(data);
//       print('Received: $receivedData');
//       // Process received data and perform actions (e.g., send orders)
//       // Here, you would parse the data and send specific instructions to the MQL5 script
//       // For instance:
//       // socket.write('{"action": "BUY", "symbol": "EURUSD", "volume": 1}');
//     });
//   }
// }
