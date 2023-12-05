import 'dart:convert';
import 'dart:io';
import 'dart:math' as math; // import this
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:kitchen_studio_10162023/model/device_stats.dart';
import 'package:kitchen_studio_10162023/model/dispense_operation.dart';
import 'package:kitchen_studio_10162023/model/motor_operation.dart';
import 'package:kitchen_studio_10162023/model/user_action_operation.dart';
import 'package:kitchen_studio_10162023/model/wash_operation.dart';
import 'package:kitchen_studio_10162023/widgets/rotating_cylinder.dart';
import 'package:kitchen_studio_10162023/service/task_runner_pool.dart';
import 'package:kitchen_studio_10162023/service/task_runner_service.dart';
import 'package:kitchen_studio_10162023/service/udp_listener.dart';
import 'package:kitchen_studio_10162023/service/udp_service.dart';
import 'package:kitchen_studio_10162023/widgets/thermometers.dart';

class CookingUnitCardComponent extends StatefulWidget {
  final DeviceStats deviceStats;
  final String? backgroundImage;

  const CookingUnitCardComponent(
      {Key? key, required this.deviceStats, this.backgroundImage})
      : super(key: key);

  @override
  State<CookingUnitCardComponent> createState() =>
      _CookingUnitCardComponentState();
}

class _CookingUnitCardComponentState extends State<CookingUnitCardComponent>
    implements UdpListener, TaskListener {
  UdpService? udpService = UdpService.instance;
  TaskRunnerPool pool = TaskRunnerPool.instance;
  final ValueNotifier<double> temperature = ValueNotifier(0.3);
  double _progress = 0.0;
  bool _busy = false;
  TaskRunner? taskRunner;
  String? _backgroundImagePath;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key
  bool _showBottomSheet = false;

  @override
  void dispose() {
    temperature.value = widget.deviceStats.temperature! / 200;
    pool.removeStatsListener(this);
    taskRunner?.removeListeners(this);
    super.dispose();
  }

  @override
  void initState() {
    taskRunner = pool.getTaskRunner(widget.deviceStats.moduleName!);
    setState(() {
      _backgroundImagePath = widget.backgroundImage;
    });
    if (taskRunner != null) {
      taskRunner?.addListeners(this);
      // if(widget.backgroundImage == null){
      //   setState(() {
      //     _backgroundImagePath = taskRunner?.getPayload()?.recipe.imageFilePath;
      //   });
      // }
    }
    pool.addStatsListener(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Card(
        child: Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.deviceStats.moduleName}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        "${(widget.deviceStats.machineTime)}",
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            _key.currentState?.showBottomSheet((context) =>
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Motor Control",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          IconButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              icon: Icon(Icons.close))
                                        ],
                                      ),
                                      ListTile(
                                        onTap: () {
                                          MotorOperation mOp =
                                              MotorOperation(2, 3, 0);
                                          udpService?.send(
                                              jsonEncode(mOp.toJson())
                                                  .codeUnits,
                                              InternetAddress(widget
                                                  .deviceStats.ipAddress!),
                                              widget.deviceStats.port!);
                                        },
                                        title: Text("Tilt Up (3°)"),
                                        trailing: Icon(Icons.arrow_upward),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          MotorOperation mOp =
                                              MotorOperation(2, -3, 0);
                                          udpService?.send(
                                              jsonEncode(mOp.toJson())
                                                  .codeUnits,
                                              InternetAddress(widget
                                                  .deviceStats.ipAddress!),
                                              widget.deviceStats.port!);
                                        },
                                        title: Text("Tilt Down (3°)"),
                                        trailing: Icon(Icons.arrow_downward),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          MotorOperation mOp =
                                              MotorOperation(2, 0, 15);
                                          udpService?.send(
                                              jsonEncode(mOp.toJson())
                                                  .codeUnits,
                                              InternetAddress(widget
                                                  .deviceStats.ipAddress!),
                                              widget.deviceStats.port!);
                                        },
                                        title: Text("Rotate Right (15°)"),
                                        trailing: Icon(Icons.arrow_forward),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          MotorOperation mOp =
                                              MotorOperation(2, 0, -15);
                                          udpService?.send(
                                              jsonEncode(mOp.toJson())
                                                  .codeUnits,
                                              InternetAddress(widget
                                                  .deviceStats.ipAddress!),
                                              widget.deviceStats.port!);
                                        },
                                        title: Text("Rotate Left (15°)"),
                                        trailing: Icon(Icons.arrow_back),
                                      ),
                                      SizedBox(
                                        height: 70,
                                        width: 40,
                                        child: RotatingCylinder(
                                            temperature: ValueNotifier(.8)),
                                      )
                                    ],
                                  ),
                                ));
                          },
                          icon: Icon(Icons.motion_photos_on_rounded)),
                      PopupMenuButton<String>(
                        enabled: !_busy,
                        icon: Icon(Icons.filter_list),
                        onSelected: (String result) {
                          switch (result) {
                            case 'zero':
                              String jsonData =
                                  '{"operation":"199","request_id":"zeroing"}';
                              udpService?.send(
                                  jsonData.codeUnits,
                                  InternetAddress(
                                      widget.deviceStats.ipAddress!),
                                  8888);
                              break;
                            case 'heat_until':
                              break;
                            case 'dispense':
                              String dispense = jsonEncode(DispenseOperation(
                                      targetTemperature: 0,
                                      currentIndex: 0,
                                      recipeId: 0,
                                      cycle: 1,
                                      id: 0,
                                      instructionSize: 0)
                                  .toJson());
                              udpService?.send(
                                  dispense.codeUnits,
                                  InternetAddress(
                                      widget.deviceStats.ipAddress!),
                                  8888);
                              break;
                            case 'wash':
                              String wash = jsonEncode(WashOperation(
                                      duration: 60,
                                      targetTemperature: 80,
                                      currentIndex: 0,
                                      recipeId: 0,
                                      cycle: 1,
                                      id: 0,
                                      instructionSize: 0)
                                  .toJson());
                              udpService?.send(
                                  wash.codeUnits,
                                  InternetAddress(
                                      widget.deviceStats.ipAddress!),
                                  8888);
                              String userAction = jsonEncode(UserActionOperation(
                                  targetTemperature: 0,
                                  currentIndex: 0,
                                  recipeId: 0,
                                  instructionSize: 0)
                                  .toJson());
                              udpService?.send(
                                  userAction.codeUnits,
                                  InternetAddress(
                                      widget.deviceStats.ipAddress!),
                                  8888);
                              break;

                              break;

                              break;
                            default:
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'zero',
                            child: Text('Reset (Zero)'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'wash',
                            child: Text('Wash'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'dispense',
                            child: Text('Dispense'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'cooling',
                            child: Text('Cooling'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'heat_until',
                            child: Text('Heat Until'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'shutdown',
                            child: Text('Shutdown'),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
              Container(
                width: double.infinity,
                height: 135,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    // _backgroundImagePath!=null? Center(
                    //   child: CircleAvatar(
                    //     radius: 65,
                    //     backgroundImage: FileImage(File(_backgroundImagePath!)),
                    //   ),
                    // ): SizedBox(),
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.black12,
                    ),
                    Container(
                      width: 130,
                      height: 130,
                      child: Thermometer(
                        temperature: temperature,
                      ),
                    ),
                    Text(
                        "${widget.deviceStats.temperature?.toStringAsFixed(2)} °C",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),

                    Positioned(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: RotatedBox(
                              quarterTurns: 2, child: progressGauge()),
                        ),
                        bottom: 0),
                  ],
                ),
              ),
              Text(
                "${widget.deviceStats.requestId}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                "${widget.deviceStats.ipAddress}:${widget.deviceStats.port}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                "${widget.deviceStats.type}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Enable Queue",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Switch(
                    value: taskRunner?.isChained() ?? false,
                    onChanged: (value) {
                      taskRunner?.setChained(value);
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget progressGauge() {
    return AnimatedRadialGauge(
        duration: const Duration(seconds: 2),
        curve: Curves.elasticOut,
        radius: 66,
        initialValue: 0,
        value: _progress ?? 0.0,
        axis: GaugeAxis(
            min: 0,
            max: 1,
            degrees: 280,
            style: const GaugeAxisStyle(
              thickness: 3,
              background: Color(0xFFDFE2EC),
              segmentSpacing: 4,
            ),
            progressBar: const GaugeProgressBar.rounded(
              color: Colors.transparent,
            ),
            segments: [
              const GaugeSegment(
                from: 0,
                to: 0.33,
                color: Colors.grey,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 0.33,
                to: 0.5,
                color: Colors.blueGrey,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 0.5,
                to: 0.8,
                color: Colors.blueAccent,
                cornerRadius: Radius.zero,
              ),
              const GaugeSegment(
                from: 0.8,
                to: 1,
                color: Colors.blue,
                cornerRadius: Radius.zero,
              ),
            ]));
  }

  @override
  void udpData(Datagram? dg) {
    if (dg != null) temperature.value = widget.deviceStats.temperature! / 200;
  }

  @override
  void onEvent(String moduleName, message,
      {required bool busy,
      required DeviceStats deviceStats,
      required double progress,
      required int index,
      UserAction? userAction}) {
    setState(() {
      _progress = progress;
      _busy = busy;
    });
  }

  @override
  void onError(ModuleError error) {
    // TODO: implement onError
  }
}
