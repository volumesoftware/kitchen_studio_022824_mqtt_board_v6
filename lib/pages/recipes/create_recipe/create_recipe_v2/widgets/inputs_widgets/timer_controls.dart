/// Flutter package imports
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Gauge import
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TimerControl extends StatefulWidget {
  const TimerControl({Key? key}) : super(key: key);

  @override
  State<TimerControl> createState() => _TimerControlState();
}

class _TimerControlState extends State<TimerControl> {
  final ValueNotifier<double> hourValueNotifier = ValueNotifier(0);
  final ValueNotifier<double> minuteValueNotifier = ValueNotifier(0);
  final ValueNotifier<double> secondValueNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26, style: BorderStyle.solid)),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: RadialTimerControl(
                      unit: 'h',
                      changeValue: hourValueNotifier,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: RadialTimerControl(
                      unit: 'm',
                      changeValue: minuteValueNotifier,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: RadialTimerControl(
                      unit: 's',
                      changeValue: secondValueNotifier,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextButton(
                      child: Text("Reset"),
                      onPressed: () {
                        hourValueNotifier.value = 0;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextButton(
                      child: Text("Reset"),
                      onPressed: () {
                        minuteValueNotifier.value = 0;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextButton(
                      child: Text("Reset"),
                      onPressed: () {
                        secondValueNotifier.value = 0;
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
          Positioned(
            child: Text(
              "Timeout / Duration",
              textAlign: TextAlign.center,
            ),
            top: 5,
            right: 5,
            left: 5,
          ),
        ],
      ),
    );
  }
}

class RadialTimerControl extends StatefulWidget {
  final String unit;
  final ValueNotifier<double> changeValue;

  const RadialTimerControl(
      {Key? key, required this.unit, required this.changeValue})
      : super(key: key);

  @override
  State<RadialTimerControl> createState() => _RadialTimerControlState();
}

class _RadialTimerControlState extends State<RadialTimerControl> {
  double _secondMarkerValue = 0;
  double _firstMarkerValue = 0;
  double _firstMarkerSize = 35;
  bool _isFirstPointer = true;
  bool _isSecondPointer = true;
  double _annotationFontSize = 25;
  String _annotationValue1 = '';
  String _annotationValue2 = '';

  @override
  void initState() {
    _annotationValue2 = '0 ${widget.unit}';

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      _firstMarkerSize = 35;
      _annotationFontSize = 15;
    } else {}

    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape
            ? true
            : false;

    return ValueListenableBuilder(
      valueListenable: widget.changeValue,
      builder: (context, value, child) {
        if (value != _secondMarkerValue) {
          _secondMarkerValue = value;
          _annotationValue2 = '${value.round()} ${widget.unit}';
        }

        return Center(
          child: SfRadialGauge(axes: <RadialAxis>[
            RadialAxis(
                showFirstLabel: false,
                startAngle: 270,
                endAngle: 270,
                radiusFactor: 0.85,
                maximum: 60,
                interval: 15,
                axisLineStyle: const AxisLineStyle(
                    color: Color.fromRGBO(128, 94, 246, 0.3),
                    thickness: 0.075,
                    thicknessUnit: GaugeSizeUnit.factor),
                tickOffset: 0.15,
                labelOffset: 0.1,
                offsetUnit: GaugeSizeUnit.factor,
                minorTicksPerInterval: 30,
                minorTickStyle: const MinorTickStyle(
                    length: 0.05, lengthUnit: GaugeSizeUnit.factor),
                majorTickStyle: const MajorTickStyle(
                    length: 0.1, lengthUnit: GaugeSizeUnit.factor),
                ranges: <GaugeRange>[
                  GaugeRange(
                      endValue: _secondMarkerValue,
                      startValue: _firstMarkerValue,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: const Color.fromRGBO(128, 94, 246, 1),
                      endWidth: 0.075,
                      startWidth: 0.075)
                ],
                pointers: <GaugePointer>[
                  MarkerPointer(
                    value: _secondMarkerValue,
                    elevation: 5,
                    markerOffset: 0.1,
                    color: const Color.fromRGBO(128, 94, 246, 1),
                    enableDragging: true,
                    markerHeight: _firstMarkerSize,
                    markerWidth: _firstMarkerSize,
                    markerType: MarkerType.circle,
                    onValueChanged: _handleSecondPointerValueChanged,
                    onValueChanging: _handleSecondPointerValueChanging,
                    onValueChangeStart: _handleSecondPointerValueStart,
                    onValueChangeEnd: _handleSecondPointerValueEnd,
                  )
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                      widget: SizedBox(
                        width: 300,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.decelerate,
                              child: AnimatedOpacity(
                                opacity: _isSecondPointer ? 1.0 : 0.0,
                                duration: (_isFirstPointer && _isSecondPointer)
                                    ? const Duration(milliseconds: 800)
                                    : const Duration(milliseconds: 200),
                                child: TimerAnimatedBuilder(
                                  value: !_isFirstPointer
                                      ? isLandscape
                                          ? 1.5
                                          : 2.0
                                      : 1.0,
                                  curve: Curves.decelerate,
                                  duration: const Duration(milliseconds: 300),
                                  builder: (BuildContext context, Widget? child,
                                          Animation<dynamic> animation) =>
                                      Transform.scale(
                                    scale: animation.value,
                                    child: child,
                                  ),
                                  child: Text(
                                    _annotationValue2,
                                    style: TextStyle(
                                        fontSize: _annotationFontSize,
                                        fontFamily: 'Times'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      angle: 90)
                ]),
          ]),
        );
      },
    );
  }

  /// Dragged pointer new value is updated to pointer and
  /// annotation current value.
  void _handleSecondPointerValueChanged(double markerValue) {

    widget.changeValue.value = markerValue;
    // setState(() {
    //   _secondMarkerValue = markerValue;
    //   final int value = _secondMarkerValue.round();
    //   _annotationValue2 = '$value ${widget.unit}';
    // });
  }

  /// Pointer dragging is canceled when dragging pointer value is less than 6.
  void _handleSecondPointerValueChanging(ValueChangingArgs args) {}

  /// Value changed call back for first pointer
  void _handleFirstPointerValueChanged(double markerValue) {
    setState(() {

      _firstMarkerValue = markerValue;
      final int value = _firstMarkerValue.round();
      _annotationValue1 = '$value ${widget.unit}';
    });
  }

  /// Value changeing call back for first pointer
  void _handleFirstPointerValueChanging(ValueChangingArgs args) {}

  void _handleFirstPointerValueStart(double value) {
    _isSecondPointer = false;
  }

  void _handleFirstPointerValueEnd(double value) {
    setState(() {
      _isSecondPointer = true;
    });
  }

  void _handleSecondPointerValueStart(double value) {
    _isFirstPointer = false;
  }

  void _handleSecondPointerValueEnd(double value) {
    setState(() {
      _isFirstPointer = true;
    });
  }

  /// Renders a given fixed size widget
  bool get isWebOrDesktop {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        kIsWeb;
  }
}

/// Widget of custom animated builder.
class TimerAnimatedBuilder extends StatefulWidget {
  /// Creates a instance for [TimerAnimatedBuilder].
  const TimerAnimatedBuilder({
    Key? key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.child,
  }) : super(key: key);

  /// Specifies the animation duration.
  final Duration duration;

  /// Specifies the curve of animation.
  final Curve curve;

  /// Specifies the animation controller value.
  final double value;

  /// Specifies the child widget.
  final Widget? child;

  /// Specifies the builder function.
  final Widget Function(
    BuildContext context,
    Widget? child,
    Animation<dynamic> animation,
  ) builder;

  @override
  _TimerAnimatedBuilderState createState() => _TimerAnimatedBuilderState();
}

class _TimerAnimatedBuilderState extends State<TimerAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      value: widget.value,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimerAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _animationController.animateTo(
        widget.value,
        duration: widget.duration,
        curve: widget.curve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) => widget.builder(
        context,
        widget.child,
        _animationController,
      ),
    );
  }
}
