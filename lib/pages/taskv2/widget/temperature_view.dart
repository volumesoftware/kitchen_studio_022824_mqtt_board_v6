// Flutter package imports
import 'package:flutter/material.dart';

/// Gauge imports
import 'package:syncfusion_flutter_gauges/gauges.dart';


class TemperatureView extends StatelessWidget {
  final double temperature;
  final double targetTemperature;

  const TemperatureView({super.key, required this.temperature, required this.targetTemperature});


  @override
  Widget build(BuildContext context) {
    return _buildHeatMeter(context);
  }

  /// Returns the heat meter.
  Widget _buildHeatMeter(BuildContext context) {
    return SfLinearGauge(
        maximum: 400.0,
        interval: 80.0,
        minorTicksPerInterval: 0,
        animateAxis: true,
        labelFormatterCallback: (String value) {
          return value + '°c';
        },
        axisTrackStyle: const LinearAxisTrackStyle(thickness: 1),
        barPointers: <LinearBarPointer>[
          LinearBarPointer(
              value: 400,
              thickness: 24,
              position: LinearElementPosition.outside,
              shaderCallback: (Rect bounds) {
                return const LinearGradient(colors: <Color>[
                  Colors.green,
                  Colors.orange,
                  Colors.red
                ], stops: <double>[
                  0.1,
                  0.4,
                  0.9,
                ]).createShader(bounds);
              }),
        ],
        markerPointers: <LinearMarkerPointer>[
          LinearWidgetPointer(
              value: temperature,
              offset: 26,
              position: LinearElementPosition.outside,
              child: SizedBox(
                  width: 55,
                  height: 45,
                  child: Center(
                      child: Text(
                        temperature.toStringAsFixed(0) + '°C',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: temperature < 20
                                ? Colors.green
                                : temperature < 60
                                ? Colors.orange
                                : Colors.red),
                      )))),
          LinearShapePointer(
            offset: 25,
            // onChanged: (dynamic value) {
            //   setState(() {
            //     temperature = value as double;
            //   });
            // },
            value: temperature,
            color: temperature < 20
                ? Colors.green
                : temperature < 60
                ? Colors.orange
                : Colors.red,
          ),



          // LinearWidgetPointer(
          //     value: targetTemperature,
          //     offset: 26,
          //     position: LinearElementPosition.outside,
          //     child: SizedBox(
          //         width: 55,
          //         height: 45,
          //         child: Center(
          //             child: Text(
          //               targetTemperature.toStringAsFixed(0) + '°C',
          //               style: TextStyle(
          //                   fontWeight: FontWeight.w500,
          //                   fontSize: 16,
          //                   color: Colors.green),
          //             )))),
          LinearShapePointer(
            offset: 25,
            value: targetTemperature,
            color: Colors.green,
          ),





        ]);
  }

}
