import 'dart:io';

import 'package:kitchen_studio_10162023/service/udp_listener.dart';

class UdpService {
  RawDatagramSocket? _udpSocket;
  UdpListener? _listener;

  UdpService._privateConstructor();

  Future initialize() async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889);
    _udpSocket?.broadcastEnabled = true;
    _udpSocket?.listen((event) {
      Datagram? dg = _udpSocket?.receive();
      if (dg != null) {
        _listener?.udpData(dg);
      }
    });
  }

  Future<void> listen(UdpListener listener) async {
    _udpSocket ??= await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889);
    _listener = listener;
  }

  void closeListener() {
    _listener = null;
    _udpSocket?.close();
  }

  int send(List<int> buffer, InternetAddress address, int port) {
    if (_udpSocket != null) {
      return _udpSocket!.send(buffer, address, port);
    } else
      return 0;
  }

  get udp => _udpSocket;

  static final UdpService _instance = UdpService._privateConstructor();

  static UdpService get instance => _instance;
}
