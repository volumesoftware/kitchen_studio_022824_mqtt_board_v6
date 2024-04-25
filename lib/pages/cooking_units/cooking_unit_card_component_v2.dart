import 'dart:convert';
import 'dart:io';
import 'dart:math' as math; // import this
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:kitchen_module/kitchen_module.dart';
import 'package:kitchen_studio_10162023/widgets/rotating_cylinder.dart';
import 'package:kitchen_studio_10162023/widgets/thermometers.dart';

class CookingUnitCardComponentV2 extends StatefulWidget {
  final RecipeProcessor recipeProcessor;
  final String? backgroundImage;

  const CookingUnitCardComponentV2({Key? key, required this.recipeProcessor, this.backgroundImage}) : super(key: key);

  @override
  State<CookingUnitCardComponentV2> createState() => _CookingUnitCardComponentV2State();
}

class _CookingUnitCardComponentV2State extends State<CookingUnitCardComponentV2> {
  final ValueNotifier<double> temperature = ValueNotifier(0.3);
  double _progress = 0.0;
  bool _busy = false;
  final GlobalKey<ScaffoldState> _key = GlobalKey(); // Create a key

  @override
  void dispose() {
    widget.recipeProcessor.hearBeat.listen((ModuleResponse stats) {
      if (stats is StirFryResponse) temperature.value = stats.temperature! / 200;
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Card(
        child: StreamBuilder(
          stream: widget.recipeProcessor.hearBeat,
          builder: (context, snapshot) {
            if ((snapshot.data == null) && (widget.recipeProcessor.getModuleResponse().moduleName == null)) {
              return Text("Loading device");
            }

            ModuleResponse? moduleResponse = snapshot.data ?? widget.recipeProcessor.getModuleResponse();

            return Container(
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
                            "${moduleResponse.moduleName}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            (timeLeft(moduleResponse.machineTime ?? 0)),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                _key.currentState?.showBottomSheet((context) => Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Motor Control",
                                                style: Theme.of(context).textTheme.titleMedium,
                                              ),
                                              IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.close))
                                            ],
                                          ),
                                          ListTile(
                                            onTap: () {
                                              MotorOperation mOp = MotorOperation(2, 3, 0);
                                            },
                                            title: Text("Tilt Up (3°)"),
                                            trailing: Icon(Icons.arrow_upward),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              MotorOperation mOp = MotorOperation(2, -3, 0);
                                            },
                                            title: Text("Tilt Down (3°)"),
                                            trailing: Icon(Icons.arrow_downward),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              MotorOperation mOp = MotorOperation(2, 0, 15);
                                            },
                                            title: Text("Rotate Right (15°)"),
                                            trailing: Icon(Icons.arrow_forward),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              MotorOperation mOp = MotorOperation(2, 0, -15);
                                            },
                                            title: Text("Rotate Left (15°)"),
                                            trailing: Icon(Icons.arrow_back),
                                          ),
                                          SizedBox(
                                            height: 70,
                                            width: 40,
                                            child: RotatingCylinder(temperature: ValueNotifier(.8)),
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
                                  String jsonData = '{"operation":"199","request_id":"zeroing"}';

                                  break;
                                case 'heat_until':
                                  break;
                                case 'dispense':
                                  String dispense = jsonEncode(DispenseOperation(
                                          currentIndex: 0, cycle: 1, targetTemperature: 0, tiltAngleB: -30, tiltAngleA: 15, tiltSpeed: 0, rotateSpeed: 0)
                                      .toJson());

                                  break;
                                case 'wash':
                                  String wash = jsonEncode(WashOperation(
                                          currentIndex: 0,
                                          duration: 30,
                                          cycle: 1,
                                          tiltAngleA: 45,
                                          tiltAngleB: 15,
                                          rotateAngle: 270,
                                          rotateSpeed: 0,
                                          tiltSpeed: 0,
                                          targetTemperature: 80)
                                      .toJson());

                                  break;
                                case 'prime_oil':
                                  String primeOil = jsonEncode({
                                    "request_id": "Prime Oil",
                                    "operation": 216,
                                    "current_index": 0,
                                    "instruction_size": 0,
                                    "target_temperature": 28.0,
                                  });

                                  break;
                                case 'prime_water':
                                  String primeWater = jsonEncode({
                                    "request_id": "Prime Water",
                                    "operation": 217,
                                    "current_index": 0,
                                    "instruction_size": 0,
                                    "target_temperature": 28.0,
                                  });

                                  break;
                                default:
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'wash',
                                child: Text('Wash'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'dispense',
                                child: Text('Dispense'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'zero',
                                child: Text('Reset (Zero)'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'prime_oil',
                                child: Text('Prime Oil'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'prime_water',
                                child: Text('Prime Water'),
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
                        (moduleResponse is StirFryResponse)
                            ? Text("${moduleResponse.temperature?.toStringAsFixed(2)} °C",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))
                            : Row(),
                        Positioned(
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(math.pi),
                              child: RotatedBox(quarterTurns: 2, child: progressGauge()),
                            ),
                            bottom: 0),
                      ],
                    ),
                  ),
                  Text(
                    "${moduleResponse.requestId}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "${moduleResponse.ipAddress}:${moduleResponse.port}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    "${moduleResponse.type}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String timeLeft(int milliseconds) {
    double seconds = milliseconds / 1000;

    String eta = "";
    if (seconds >= 60) {
      eta = (seconds / 60).toStringAsFixed(2);
      return "$eta minutes";
    } else if (seconds >= 3600) {
      eta = (seconds / (60 * 60)).toStringAsFixed(2);
      return "$eta hours";
    } else {
      return "$seconds seconds";
    }
  }

  Widget progressGauge() {
    return AnimatedRadialGauge(
        duration: const Duration(seconds: 2),
        curve: Curves.elasticOut,
        radius: 66,
        initialValue: 0,
        value: _progress,
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
}
