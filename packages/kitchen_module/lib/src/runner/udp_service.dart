// import 'dart:io';
//
// abstract interface class UdpListener {
//   void udpData(Datagram dg);
// }
//
// class UdpService {
//   RawDatagramSocket? _udpSocket;
//   UdpListener? _listener;
//
//   UdpService._privateConstructor() {
//     _initialize();
//   }
//
//   Future _initialize() async {
//     print('udp service initialized');
//     _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8899);
//     _udpSocket?.broadcastEnabled = true;
//     _udpSocket?.listen((event) {
//       Datagram? dg = _udpSocket?.receive();
//       if (dg != null) {
//         _listener?.udpData(dg);
//       }
//     });
//   }
//
//   Future<void> listen(UdpListener listener) async {
//     _listener = listener;
//   }
//
//   void closeListener() {
//     _listener = null;
//     _udpSocket?.close();
//   }
//
//   int send(List<int> buffer, InternetAddress address, int port) {
//     if (_udpSocket != null) {
//       return _udpSocket!.send(buffer, address, port);
//     } else {
//       return 0;
//     }
//   }
//
//   get udp => _udpSocket;
//
//   static final UdpService _instance = UdpService._privateConstructor();
//
//   static UdpService get instance => _instance;
// }
