import 'dart:io';

abstract interface class UdpListener {
  void udpData(Datagram? dg);
}
