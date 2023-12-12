import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:database_service/database_service.dart';

class KitchenModulePool implements UdpListener {

  KitchenModulePool._privateConstructor() {
    initialize();
  }

  static final KitchenModulePool _instance =
  KitchenModulePool._privateConstructor();

  static KitchenModulePool get instance => _instance;



  Map<String, DeviceStats> _deviceMap = {};
  //store the
  StreamController<Map<String, DeviceStats>> _stateChangesController =
      StreamController<Map<String, DeviceStats>>.broadcast();
  final UdpService _udpService = UdpService.instance;
  final DeviceDataAccess deviceDataAccess = DeviceDataAccess.instance;

  //listen to the state change of the devices
  Stream<Map<String, DeviceStats>> get stateChanges =>
      _stateChangesController.stream;

  //get device map
  Map<String, DeviceStats> get devices =>
      Map<String, DeviceStats>.from(_deviceMap);

  void initialize() {
    print("initializing kitchen module pool");
    _udpService.listen(this);
    String jsonData = '{"operation":100}';
    _udpService.send(jsonData.codeUnits, InternetAddress("192.168.43.255"), 8888);
    Timer.periodic(
      Duration(seconds: 5),
      (timer) {
        // print('sending ${jsonData}');
        _udpService.send(
            jsonData.codeUnits, InternetAddress("192.168.43.255"), 8888);
      },
    );

    stateChanges.listen((Map<String, DeviceStats> devices) async {
      for (var device in devices.entries) {
        var list =
            await deviceDataAccess.search('ip = ?', whereArgs: [device.key]);
        if (list != null) {
          if (list.isEmpty) {
            int? id = await deviceDataAccess.create(device.value);
          }
        }
      }
    });
  }

  @override
  Future<void> udpData(Datagram dg) async {
    try {
      String result = String.fromCharCodes(dg.data);
      DeviceStats incomingStats = DeviceStats.fromJson(jsonDecode(result));
      _deviceMap[incomingStats.ipAddress!] = incomingStats;
      _stateChangesController.sink.add(Map<String, DeviceStats>.from(_deviceMap));
    } catch (e) {
      print(e);
    }
  }

  void dispose() {
    _stateChangesController.close();
  }
}
