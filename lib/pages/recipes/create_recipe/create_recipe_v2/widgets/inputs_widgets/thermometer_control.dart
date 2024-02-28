import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ThermometerControls extends StatefulWidget {
  final ValueChanged<double> valueChanged;
  final VoidCallback onChangeStart;
  final VoidCallback onChangeEnd;

  const ThermometerControls(
      {Key? key,
      required this.valueChanged,
      required this.onChangeStart,
      required this.onChangeEnd})
      : super(key: key);

  @override
  State<ThermometerControls> createState() => _ThermometerControlsState();
}

class _ThermometerControlsState extends State<ThermometerControls> {
  double _meterValue = 35;
  final double _temperatureValue = 80;

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final Brightness brightness = Theme.of(context).brightness;

    return Stack(
      children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /// Linear gauge to display celsius scale.
                SfLinearGauge(
                    minimum: 20,
                    maximum: 300,
                    interval: 100,
                    minorTicksPerInterval: 0,
                    axisTrackExtent: 23,
                    axisTrackStyle: LinearAxisTrackStyle(
                        thickness: 12,
                        borderWidth: 1,
                        edgeStyle: LinearEdgeStyle.bothCurve),
                    tickPosition: LinearElementPosition.outside,
                    labelPosition: LinearLabelPosition.outside,
                    orientation: LinearGaugeOrientation.vertical,
                    markerPointers: <LinearMarkerPointer>[
                      LinearShapePointer(
                        value: 20,
                        markerAlignment: LinearMarkerAlignment.start,
                        shapeType: LinearShapePointerType.circle,
                        borderWidth: 1,
                        borderColor: brightness == Brightness.dark
                            ? Colors.white30
                            : Colors.black26,
                        position: LinearElementPosition.cross,
                        width: 24,
                        height: 24,
                      ),
                      LinearShapePointer(
                        value: 20,
                        markerAlignment: LinearMarkerAlignment.start,
                        shapeType: LinearShapePointerType.circle,
                        borderWidth: 6,
                        borderColor: Colors.transparent,
                        color: _meterValue > _temperatureValue
                            ? const Color(0xffFF7B7B)
                            : const Color(0xff0074E3),
                        position: LinearElementPosition.cross,
                        width: 24,
                        height: 24,
                      ),
                      LinearWidgetPointer(
                          value: 20,
                          markerAlignment: LinearMarkerAlignment.start,
                          child: Container(
                            width: 10,
                            height: 3.4,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  width: 2.0,
                                ),
                                right: BorderSide(
                                  width: 2.0,
                                ),
                              ),
                              color: _meterValue > _temperatureValue
                                  ? const Color(0xffFF7B7B)
                                  : const Color(0xff0074E3),
                            ),
                          )),
                      LinearWidgetPointer(
                          value: _meterValue,
                          enableAnimation: false,
                          position: LinearElementPosition.outside,
                          onChanged: (dynamic value) {
                            setState(() {
                              _meterValue = value as double;
                              widget.valueChanged(_meterValue);
                            });
                          },
                          onChangeStart: (value) {
                            widget.onChangeStart();
                          },
                          onChangeEnd: (value) {
                            widget.onChangeEnd();
                          },
                          child: Container(
                              width: 16,
                              height: 12,
                              transform:
                                  Matrix4.translationValues(-16, -18, 0.0),
                              child: Icon(
                                Icons.arrow_right,
                                size: 64,
                              ))),
                      LinearShapePointer(
                        value: _meterValue,
                        width: 20,
                        height: 20,
                        enableAnimation: false,
                        color: Colors.transparent,
                        position: LinearElementPosition.cross,
                        onChangeStart: (value) {
                          widget.onChangeStart();
                        },
                        onChangeEnd: (value) {
                          widget.onChangeEnd();
                        },
                        onChanged: (dynamic value) {
                          setState(() {
                            _meterValue = value as double;
                            widget.valueChanged(_meterValue);
                          });
                        },
                      )
                    ],
                    barPointers: <LinearBarPointer>[
                      LinearBarPointer(
                        value: _meterValue,
                        enableAnimation: false,
                        thickness: 6,
                        edgeStyle: LinearEdgeStyle.endCurve,
                        color: _meterValue > _temperatureValue
                            ? const Color(0xffFF7B7B)
                            : const Color(0xff0074E3),
                      )
                    ]),

                /// Linear gauge to display Fahrenheit  scale.
              ],
            )),
        Positioned(child: Text("Timeout / Duration", textAlign: TextAlign.center,), top: 5, right: 5, left: 5,),

      ],
    );
  }
}
