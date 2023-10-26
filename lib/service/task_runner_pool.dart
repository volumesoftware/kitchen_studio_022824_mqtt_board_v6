import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:kitchen_studio_10162023/dao/device_data_access.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/service/task_runner_service.dart';
import 'package:kitchen_studio_10162023/service/udp_listener.dart';
import 'package:kitchen_studio_10162023/service/udp_service.dart';

class TaskRunnerPool implements UdpListener {
  final List<DeviceStats> _devices = [];
  final UdpService _udpService = UdpService.instance;
  final Map<String, TaskRunner> _taskRunners = {};
  final DeviceDataAccess deviceDataAccess = DeviceDataAccess.instance;
  final List<UdpListener> _statsListener = [];
  final List<TaskListener> _taskListener = [];



  TaskRunnerPool._privateConstructor();

  static final TaskRunnerPool _instance = TaskRunnerPool._privateConstructor();

  static TaskRunnerPool get instance => _instance;

  List<DeviceStats> getDevices(){
    _devices.sort((a, b) => a.moduleName!.compareTo(b.moduleName!),);
    return _devices;
  }


  void addStatsListener(UdpListener listener) {
    _statsListener.add(listener);
  }

  void removeStatsListener(UdpListener listener) {
    _statsListener.remove(listener);
  }

  void initialize() {
    _udpService.listen(this);
    String jsonData = '{"operation":100}';
    UdpService.instance.listen(this);
    _udpService.send(
        jsonData.codeUnits, InternetAddress("192.168.43.255"), 8888);
    Timer.periodic(Duration(seconds: 3),
          (timer) {
        _udpService.send(jsonData.codeUnits, InternetAddress("192.168.43.255"), 8888);
      },
    );
  }

  void _populateDevices() {
    for (var element in _devices) {
      var containsKey = _taskRunners.containsKey(element.moduleName);
      if (!containsKey) {
        _taskRunners[element.moduleName!] = TaskRunner(element);
      } else {
        _taskRunners[element.moduleName!]?.updateStats(element);
      }
    }
  }

  TaskRunner? getTaskRunner(String moduleName) {
    return _taskRunners[moduleName];
  }


  List<TaskRunner>? getTaskRunners() {
    var list = _taskRunners.values.toList();
    list.sort((a, b) => a.moduleName!.compareTo(b.moduleName!),);
    return list;
  }

  @override
  void udpData(Datagram? dg) {

    if (dg != null) {
      String result = String.fromCharCodes(dg.data);
      DeviceStats incomingStats = DeviceStats.fromJson(jsonDecode(result));
      bool newItem = true;
      for (var element in _devices) {
        var indexOf = _devices.indexOf(element);
        if (element.ipAddress == incomingStats.ipAddress) {
          _devices[indexOf] = incomingStats;
          newItem = false;
        }
      }
      if (newItem) _devices.add(incomingStats);
      _devices.forEach((unit) async {
        try {
          var list = await deviceDataAccess
              .search('ip_address = ?', whereArgs: [unit.ipAddress!]);
          if (list != null) {
            if (list.isEmpty) {
              await deviceDataAccess.create(unit);
            }
          }
        } catch (e) {}
      });
      _populateDevices();

      _statsListener.forEach((listener) {
        listener.udpData(dg);
      });
    }
  }
}
