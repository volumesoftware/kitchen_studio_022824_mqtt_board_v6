/// Flutter package imports
import 'dart:ui';

import 'package:flutter/material.dart';

/// Gauge imports
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class RadialThermometerControls extends StatefulWidget {
  final double targetTemperature;
  final ValueChanged valueChanged;

  const RadialThermometerControls(
      {Key? key, required this.targetTemperature, required this.valueChanged})
      : super(key: key);

  @override
  State<RadialThermometerControls> createState() =>
      _RadialThermometerControlsState();
}

class _RadialThermometerControlsState extends State<RadialThermometerControls> {
  double _currentValue = 60;
  double _markerValue = 58;
  late TextEditingController _temperatureController;

  @override
  void initState() {
    _markerValue = widget.targetTemperature;
    _temperatureController = TextEditingController(text: '${_markerValue}');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26, style: BorderStyle.solid)),
      child: Stack(
        children: [
          _buildRangeThicknessExampleGauge(),
          Positioned(
              bottom: 0,
              left: 50,
              right: 50,
              child: SizedBox(
                child: SfSlider(
                  min: 30,
                  max: 300,
                  onChanged: handlePointerValueChanged,
                  value: _currentValue,
                ),
              )),
          const Positioned(
            top: 5,
            right: 5,
            left: 5,
            child: Text(
              "Target Temperature",
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                  width: 90,
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _markerValue = double.tryParse(value)??0.0;
                      });
                    },
                    decoration: InputDecoration(
                        suffixText: "°C", border: OutlineInputBorder()),
                    controller: _temperatureController,
                  ),
                )
              ],
            ),
          )

          //  Positioned(
          //   bottom: 80,
          //   right: 5,
          //   left: 5,
          //   child: Text(
          //     "${_markerValue}°C",
          //     textAlign: TextAlign.center,
          //     style: Theme.of(context).textTheme.titleLarge,
          //   ),
          // ),
        ],
      ),
    );
  }

  /// Dragged pointer new value is updated to pointer and
  /// annotation current value.
  void handlePointerValueChanged(dynamic value) {
    if (value.toInt() > 6) {
      setState(() {
        _currentValue = value.roundToDouble();
        final int currentValue = _currentValue.toInt();
        _markerValue = _currentValue - 2;
        _temperatureController.text = '$_markerValue';
      });
      widget.valueChanged(_markerValue);
    }
  }

  /// Returns the range thickness gauge
  SfRadialGauge _buildRangeThicknessExampleGauge() {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
            maximum: 300,
            showAxisLine: false,
            ticksPosition: ElementsPosition.outside,
            labelsPosition: ElementsPosition.outside,
            radiusFactor: 0.9,
            canRotateLabels: true,
            showLastLabel: true,
            majorTickStyle: const MajorTickStyle(
              length: 0.1,
              lengthUnit: GaugeSizeUnit.factor,
            ),
            minorTickStyle: const MinorTickStyle(
              length: 0.04,
              lengthUnit: GaugeSizeUnit.factor,
            ),
            minorTicksPerInterval: 5,
            interval: 30,
            axisLabelStyle: const GaugeTextStyle(),
            useRangeColorForAxis: true,
            pointers: <GaugePointer>[
              NeedlePointer(
                  enableAnimation: true,
                  value: _markerValue,
                  tailStyle: TailStyle(length: 0.2, width: 5),
                  needleEndWidth: 5,
                  needleLength: 0.7,
                  knobStyle: KnobStyle())
            ],
            ranges: <GaugeRange>[
              GaugeRange(
                  startValue: 30,
                  endValue: 300,
                  startWidth: 0.2,
                  gradient: const SweepGradient(colors: <Color>[
                    Color(0xFF0974C0),
                    Color(0xFFFAAD61),
                    Color(0xFFFF3C00)
                  ], stops: <double>[
                    0.18,
                    0.25,
                    0.75
                  ]),
                  rangeOffset: 0.08,
                  endWidth: 0.2,
                  sizeUnit: GaugeSizeUnit.factor)
            ]),
      ],
    );
  }
}
