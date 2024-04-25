/// Flutter package imports
import 'package:flutter/material.dart';

/// Gauge imports
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ModuleItems extends StatefulWidget {
  ModuleItems({Key? key, required this.percentValue, required this.temperatureValue, required this.targetTemperatureValue}) : super(key: key);

  final double percentValue;

  final double temperatureValue;

  final double targetTemperatureValue;

  @override
  State<ModuleItems> createState() => _ModuleItemsState();
}

class _ModuleItemsState extends State<ModuleItems> {
  bool isCardView = true;
  double width = 35;
  double spacer = 20;

  @override
  Widget build(BuildContext context) {
    return _buildVolumeControl();
  }

  /// Returns the volume settings.
  Widget _buildVolumeControl() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      SizedBox(
          height: isCardView ? 205 : 240,
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              child: SfLinearGauge(
                  orientation: LinearGaugeOrientation.vertical,
                  interval: 20.0,
                  showTicks: false,
                  showLabels: false,
                  minimum: 15,
                  maximum: 320,
                  minorTicksPerInterval: 0,
                  axisTrackStyle: LinearAxisTrackStyle(
                    thickness: width,
                    edgeStyle: LinearEdgeStyle.bothCurve,
                    borderWidth: 0,
                  ),
                  barPointers: <LinearBarPointer>[
                    LinearBarPointer(
                        enableAnimation: false,
                        value: widget.temperatureValue,
                        thickness: width,
                        edgeStyle: LinearEdgeStyle.bothCurve,
                        color: widget.temperatureValue < 80
                            ? Colors.blueAccent
                            : widget.temperatureValue < 150
                                ? Colors.orangeAccent
                                : Colors.redAccent)
                  ],
                  markerPointers: <LinearMarkerPointer>[
                    LinearWidgetPointer(
                      value: 5,
                      enableAnimation: false,
                      markerAlignment: LinearMarkerAlignment.end,
                      child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Center(
                              child: Icon(
                            widget.temperatureValue > 0 ? Icons.compare_arrows : Icons.compare_arrows,
                            color: const Color(0xffFFFFFF),
                          ))),
                    ),
                    LinearWidgetPointer(
                        markerAlignment: LinearMarkerAlignment.end,
                        value: 320,
                        enableAnimation: false,
                        child: SizedBox(
                          height: 25,
                          child: Text(widget.temperatureValue.toStringAsFixed(0) + '°C'),
                        )),
                    LinearShapePointer(
                        value: widget.temperatureValue - 20,
                        enableAnimation: false,
                        onChanged: (dynamic value) {
                          // setState(() {
                          //   _temperatureValue = value as double;
                          // });
                        },
                        color: Colors.transparent,
                        width: 40,
                        position: LinearElementPosition.cross,
                        shapeType: LinearShapePointerType.circle,
                        markerAlignment: LinearMarkerAlignment.end,
                        height: 40),
                  ]))),
      SizedBox(
        width: spacer,
      ),
      SizedBox(
          height: isCardView ? 205 : 240,
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              child: SfLinearGauge(
                  orientation: LinearGaugeOrientation.vertical,
                  interval: 20.0,
                  showTicks: false,
                  showLabels: false,
                  minimum: 15,
                  maximum: 320,
                  minorTicksPerInterval: 0,
                  axisTrackStyle: LinearAxisTrackStyle(
                    thickness: width,
                    edgeStyle: LinearEdgeStyle.bothCurve,
                    borderWidth: 0,
                  ),
                  barPointers: <LinearBarPointer>[
                    LinearBarPointer(
                        enableAnimation: false,
                        value: widget.targetTemperatureValue,
                        thickness: width,
                        edgeStyle: LinearEdgeStyle.bothCurve,
                        color: widget.targetTemperatureValue < 80
                            ? Colors.blueAccent
                            : widget.targetTemperatureValue < 150
                                ? Colors.orangeAccent
                                : Colors.redAccent)
                  ],
                  markerPointers: <LinearMarkerPointer>[
                    LinearWidgetPointer(
                      value: 5,
                      enableAnimation: false,
                      markerAlignment: LinearMarkerAlignment.end,
                      child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Center(
                              child: Icon(
                            widget.targetTemperatureValue > 0 ? Icons.thermostat : Icons.thermostat_sharp,
                            color: const Color(0xffFFFFFF),
                          ))),
                    ),
                    LinearWidgetPointer(
                        markerAlignment: LinearMarkerAlignment.end,
                        value: 320,
                        enableAnimation: false,
                        child: SizedBox(
                          height: 25,
                          child: Text(widget.targetTemperatureValue.toStringAsFixed(0) + '°C'),
                        )),
                    LinearShapePointer(
                        value: widget.targetTemperatureValue - 20,
                        enableAnimation: false,
                        onChanged: (dynamic value) {
                          // setState(() {
                          //   _targetTemperatureValue = value as double;
                          // });
                        },
                        color: Colors.transparent,
                        width: 40,
                        position: LinearElementPosition.cross,
                        shapeType: LinearShapePointerType.circle,
                        markerAlignment: LinearMarkerAlignment.end,
                        height: 40),
                  ]))),
    ]);
  }
}
