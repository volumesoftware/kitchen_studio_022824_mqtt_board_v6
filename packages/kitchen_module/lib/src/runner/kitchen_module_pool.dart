import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:database_service/database_service.dart';

class KitchenModulePool implements UdpListener {
  KitchenModulePool._privateConstructor() {
    initialize(dummy: false);
  }

  static final KitchenModulePool _instance =
      KitchenModulePool._privateConstructor();

  static KitchenModulePool get instance => _instance;

  Map<String, ModuleResponse> _deviceMap = {};
  // Map<String, DeviceStats> _deviceMap = {};

  //store the
  StreamController<Map<String, ModuleResponse>> _stateChangesController = StreamController<Map<String, ModuleResponse>>.broadcast();
  final UdpService _udpService = UdpService.instance;

  //listen to the state change of the devices
  Stream<Map<String, ModuleResponse>> get stateChanges =>_stateChangesController.stream;

  //get device map
  Map<String, ModuleResponse> get devices => Map<String, ModuleResponse>.from(_deviceMap);

  void initialize({required bool dummy}) {
    print("initializing kitchen module pool");
    _udpService.listen(this);
    String jsonData = '{"operation":100}';
    _udpService.send(jsonData.codeUnits,
        InternetAddress(dummy ? "192.168.1.255" : "192.168.43.255"), 8888);
    Timer.periodic(
      Duration(seconds: 5),
      (timer) {
        // print('sending ${jsonData}');
        _udpService.send(jsonData.codeUnits,
            InternetAddress(dummy ? "192.168.1.255" : "192.168.43.255"), 8888);
      },
    );


  }

  @override
  Future<void> udpData(Datagram dg) async {
    try {
      String result = String.fromCharCodes(dg.data);
      var parsedJson = jsonDecode(result);
      ModuleResponse? moduleResponse;
      if (parsedJson['type'] == 'STIR_FRY_MODULE') {
        moduleResponse = StirFryResponse(parsedJson);
      } else if (parsedJson['type'] == 'TRANSPORTER_MODULE') {
        moduleResponse = TransporterResponse(parsedJson);
      }else{
        throw HandshakeException("Failed to handshake with incoming response with type, ${parsedJson['type']}");
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
