import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/pages/cooking_units/cooking_unit_card_component.dart';
import 'package:kitchen_studio_10162023/service/database_service.dart';
import 'package:kitchen_studio_10162023/service/udp_listener.dart';
import 'package:kitchen_studio_10162023/service/udp_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CookingUnitsPage extends StatefulWidget {
  const CookingUnitsPage({Key? key}) : super(key: key);

  @override
  State<CookingUnitsPage> createState() => _CookingUnitsPageState();
}

class _CookingUnitsPageState extends State<CookingUnitsPage>
    implements UdpListener {
  Timer? timer;
  UdpService? udpService = UdpService.instance;
  Database? connectedDatabase;

  List<DeviceStats> devices = [];

  @override
  void dispose() {
    timer?.cancel();
    udpService?.removeListener(this);
    super.dispose();
  }

  @override
  void initState() {
    var instance = DatabaseService.instance;
    connectedDatabase = instance.connectedDatabase;
    try {
      connectedDatabase?.query('DeviceStats').then(
        (value) {
          if (value.isNotEmpty) {
            for (var mappedUnits in value) {
              setState(() {
                devices.add(DeviceStats.fromDatabase(mappedUnits));
              });
            }
          }
        },
      );
    } catch (e) {}

    String jsonData = '{"operation":100}';
    UdpService.instance.addListener(this);
    udpService?.send(
        jsonData.codeUnits, InternetAddress("192.168.43.255"), 8888);
    timer = Timer.periodic(
      Duration(seconds: 3),
      (timer) {
        udpService?.send(
            jsonData.codeUnits, InternetAddress("192.168.43.255"), 8888);
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Cooking Units"),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.refresh))]),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: .78,
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return CookingUnitCardComponent(deviceStats: devices[index]);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await _displayTextInputDialog(context);
          },
          label: Row(
            children: [Text("Add Units"), Icon(Icons.add)],
          )),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add new unit'),
          content: TextField(
            decoration: InputDecoration(hintText: "Unit Ip Address"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void udpData(Datagram? dg) {
    if (dg != null) {
      String result = String.fromCharCodes(dg.data);
      DeviceStats incomingStats = DeviceStats.fromJson(jsonDecode(result));
      bool newItem = true;
      devices.forEach((element) {
        var indexOf = devices.indexOf(element);
        if (element.ipAddress == incomingStats.ipAddress) {
          setState(() {
            devices[indexOf] = incomingStats;
          });
          newItem = false;
        }
      });
      if (newItem)
        setState(() {
          devices.add(incomingStats);
        });
      devices.forEach((unit) async {
        try {
          var list = await connectedDatabase!.query('DeviceStats',
              where: 'ip_address = ?', whereArgs: [unit.ipAddress]);
          if (list.isEmpty) {
            await connectedDatabase!.insert('DeviceStats', {
              'ip_address': unit.ipAddress,
              'port': unit.port,
              'module_name': unit.moduleName,
              'type': unit.type,
              'v5': unit.v5,
              'code': unit.code,
              'request_id': unit.requestId,
              'memory_usage': unit.memoryUsage,
              'progress': unit.progress,
              'water_valve_open': unit.waterValveOpen == true ? 1 : 0,
              'water_jet_open': unit.waterJetOpen == true ? 1 : 0,
              'temperature_1': unit.temperature1,
              'temperature_2': unit.temperature2,
              'current_local_time': unit.currentLocalTime,
              'local_time_max': unit.localTimeMax,
              'machine_time': unit.machineTime,
              'target_temperature': unit.targetTemperature,
              'instruction_size': unit.instructionSize
            });
          }
        } catch (e) {}
      });
    }
  }
}
