import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/dao/device_data_access.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/pages/cooking_units/cooking_unit_card_component.dart';
import 'package:kitchen_studio_10162023/service/task_runner_pool.dart';
import 'package:kitchen_studio_10162023/service/udp_listener.dart';
import 'package:kitchen_studio_10162023/service/udp_service.dart';

class CookingUnitsPage extends StatefulWidget {
  const CookingUnitsPage({Key? key}) : super(key: key);

  @override
  State<CookingUnitsPage> createState() => _CookingUnitsPageState();
}

class _CookingUnitsPageState extends State<CookingUnitsPage>
    implements UdpListener {
  Timer? timer;
  UdpService? udpService = UdpService.instance;
  TaskRunnerPool taskRunnerPool = TaskRunnerPool.instance;
  DeviceDataAccess deviceDataAccess = DeviceDataAccess.instance;

  List<DeviceStats> devices = [];

  @override
  void dispose() {
    timer?.cancel();
    taskRunnerPool.removeStatsListener(this);
    super.dispose();
  }

  @override
  void initState() {
    deviceDataAccess.findAll().then(
      (value) {
        if (value != null) {
          devices = value;
        }
      },
    );
    this.taskRunnerPool.addStatsListener(this);

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
            childAspectRatio: .65,
            crossAxisCount: 6,
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
      var incomingDevices = taskRunnerPool.getDevices();
      setState(() {
        devices = incomingDevices;
      });
    }
  }
}
