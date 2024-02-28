/// Flutter package imports
import 'package:flutter/material.dart';

/// Gauge imports
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ProgressView extends StatelessWidget {
  final double progressvalue;

  const ProgressView({super.key, required this.progressvalue});

  @override
  Widget build(BuildContext context) {
    return _buildProgressBar(context);
  }

  /// Returns the progress bar.
  Widget _buildProgressBar(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;

    return Stack(children: <Widget>[
      Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                      height: 30,
                      child: SfLinearGauge(
                        showTicks: false,
                        showLabels: false,
                        animateAxis: true,
                        axisTrackStyle: LinearAxisTrackStyle(
                          thickness: 30,
                          edgeStyle: LinearEdgeStyle.bothCurve,
                          borderWidth: 1,
                          borderColor: brightness == Brightness.dark
                              ? const Color(0xff898989)
                              : Colors.grey[350],
                          color: brightness == Brightness.dark
                              ? Colors.transparent
                              : Colors.grey[350],
                        ),
                        barPointers:  <LinearBarPointer>[
                          LinearBarPointer(
                              value: progressvalue,
                              thickness: 30,
                              edgeStyle: LinearEdgeStyle.bothCurve,
                              color: Colors.blue),
                        ],
                      ))))),
      Align(
          alignment: Alignment.centerLeft,
          child: Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                progressvalue.toStringAsFixed(2) + '%',
                style: const TextStyle(fontSize: 14, color: Color(0xffFFFFFF)),
              ))),
    ]);
  }
}
