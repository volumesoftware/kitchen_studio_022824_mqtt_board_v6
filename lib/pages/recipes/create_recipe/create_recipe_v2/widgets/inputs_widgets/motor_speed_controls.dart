///flutter package import
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

///Core theme import
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';

///Slider import
import 'package:syncfusion_flutter_sliders/sliders.dart';

///Local imports

class MotorSpeedControls extends StatefulWidget {
  const MotorSpeedControls({Key? key}) : super(key: key);

  @override
  State<MotorSpeedControls> createState() => _MotorSpeedControlsState();
}

class _MotorSpeedControlsState extends State<MotorSpeedControls> {
  double _stepSliderValue = 0;


  SfSliderTheme _sliderWithStepCustomization() {
    return SfSliderTheme(
        data: SfSliderThemeData(tooltipBackgroundColor: Colors.black87),
        child: SfSlider(
            showLabels: true,
            interval: 1,
            min: 0,
            max: 4,
            stepSize: 1,
            showTicks: true,
            value: _stepSliderValue,
            onChanged: (dynamic values) {
              setState(() {
                _stepSliderValue = values as double;
              });
            },
            enableTooltip: true));
  }

  Widget _buildWebLayout() {
    final double padding = MediaQuery.of(context).size.width / 20.0;
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _sliderWithStepCustomization(),
          ],
        ));

  }



  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget slider =_buildWebLayout();
          return constraints.maxHeight > 300
              ? slider
              : SingleChildScrollView(child: SizedBox(height: 300, child: slider));
        });
  }
}
