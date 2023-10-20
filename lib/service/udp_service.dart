import 'dart:io';

import 'package:kitchen_studio_10162023/service/udp_listener.dart';

class UdpService {
  RawDatagramSocket? _udpSocket;

  List<UdpListener> listeners = [];

  UdpService._privateConstructor();

  Future initialize() async {
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8889);
    _udpSocket?.broadcastEnabled = true;
    _udpSocket?.listen((event) {
      Datagram? dg = _udpSocket?.receive();
      if (dg != null) {}
      listeners.forEach((element) {
        element.udpData(dg);
      });
    });
  }

  void addListener(UdpListener listener) {
    this.listeners.add(listener);
  }

  void removeListener(UdpListener listener) {
    this.listeners.remove(listener);
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
