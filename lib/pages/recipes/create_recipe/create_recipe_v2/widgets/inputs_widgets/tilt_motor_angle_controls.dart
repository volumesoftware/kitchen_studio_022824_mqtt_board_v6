/// Flutter package imports
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kitchen_studio_10162023/pages/recipes/create_recipe/create_recipe_v2/widgets/inputs_widgets/input_widget.dart';

/// Gauge import
import 'package:syncfusion_flutter_gauges/gauges.dart';


class TiltMotorAngle{
  final double angleA;
  final double angleB;

  TiltMotorAngle(this.angleA, this.angleB);
}

class TiltMotorAngleControls extends StatefulWidget {

  final double angleA;
  final double angleB;
  final ValueChanged<TiltMotorAngle> valueChanged;


  const TiltMotorAngleControls({Key? key, required this.angleA, required this.angleB, required this.valueChanged}) : super(key: key);

  @override
  State<TiltMotorAngleControls> createState() => _TiltMotorAngleControlsState();
}

class _TiltMotorAngleControlsState extends State<TiltMotorAngleControls> {
  double _firstMarkerValue = 30;
  double _secondMarkerValue = 90;
  double valueOffset = -30.0;

  double _firstMarkerSize = 24;
  bool _isFirstPointer = true;
  bool _isSecondPointer = true;
  double _annotationFontSize = 15;
  String _annotationValue1 = 'A ${0}°';
  String _annotationValue2 = 'B ${90 - 30}°';

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      _firstMarkerSize = 24;
      _annotationFontSize = 15;
    } else {
      _firstMarkerSize = 24;
      _annotationFontSize = 15;
    }

    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape
            ? true
            : false;

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black26, style: BorderStyle.solid)),
      child: Stack(
        children: [
          Positioned(
            child: Transform.rotate(
              angle: 0.55,
              child: SfRadialGauge(axes: <RadialAxis>[
                RadialAxis(
                    showFirstLabel: false,
                    isInversed: true,
                    startAngle: 180,
                    endAngle: 0,
                    radiusFactor: 0.85,
                    showLabels: false,
                    maximum: 180,
                    canRotateLabels: true,
                    interval: 45,
                    axisLineStyle: const AxisLineStyle(
                        color: Color.fromRGBO(128, 94, 246, 0.3),
                        thickness: 0.075,
                        thicknessUnit: GaugeSizeUnit.factor),
                    tickOffset: 0.15,
                    labelOffset: 0.1,
                    offsetUnit: GaugeSizeUnit.factor,
                    minorTicksPerInterval: 1,
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
                        value: _firstMarkerValue,
                        elevation: 5,
                        enableDragging: true,
                        color: Colors.red,
                        markerHeight: _firstMarkerSize,
                        markerWidth: _firstMarkerSize,
                        markerType: MarkerType.diamond,
                        onValueChanged: _handleFirstPointerValueChanged,
                        onValueChanging: _handleFirstPointerValueChanging,
                        onValueChangeStart: _handleFirstPointerValueStart,
                        onValueChangeEnd: _handleFirstPointerValueEnd,
                      ),
                      MarkerPointer(
                        value: _secondMarkerValue,
                        elevation: 5,
                        markerOffset: 0.1,
                        color: Colors.green,
                        enableDragging: true,
                        markerHeight: _firstMarkerSize,
                        markerWidth: _firstMarkerSize,
                        markerType: MarkerType.diamond,
                        onValueChanged: _handleSecondPointerValueChanged,
                        onValueChanging: _handleSecondPointerValueChanging,
                        onValueChangeStart: _handleSecondPointerValueStart,
                        onValueChangeEnd: _handleSecondPointerValueEnd,
                      )
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          widget: Transform.rotate(
                            angle: -0.55,
                            child: SizedBox(
                              width: 300,
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: <Widget>[
                                  AnimatedPositioned(
                                    right:
                                        (_isFirstPointer && !_isSecondPointer)
                                            ? 120
                                            : 140,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.decelerate,
                                    child: AnimatedOpacity(
                                      opacity: _isFirstPointer ? 1.0 : 0.0,
                                      duration: (_isFirstPointer &&
                                              _isSecondPointer)
                                          ? const Duration(milliseconds: 800)
                                          : const Duration(milliseconds: 200),
                                      child: CustomAnimatedBuilder(
                                        value: !_isSecondPointer
                                            ? isLandscape
                                                ? 1.5
                                                : 2.0
                                            : 1.0,
                                        curve: Curves.decelerate,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        builder: (BuildContext context,
                                                Widget? child,
                                                Animation<dynamic> animation) =>
                                            Transform.scale(
                                          scale: animation.value,
                                          child: child,
                                        ),
                                        child: Text(
                                          _annotationValue1,
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: _annotationFontSize,
                                              fontFamily: 'Times'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    opacity:
                                        (_isSecondPointer && _isFirstPointer)
                                            ? 1.0
                                            : 0.0,
                                    duration:
                                        (_isFirstPointer && _isSecondPointer)
                                            ? const Duration(milliseconds: 800)
                                            : const Duration(milliseconds: 200),
                                    child: Text(
                                      '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: _annotationFontSize,
                                          fontFamily: 'Times'),
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    left: (_isSecondPointer && !_isFirstPointer)
                                        ? 120
                                        : 140,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.decelerate,
                                    child: AnimatedOpacity(
                                      opacity: _isSecondPointer ? 1.0 : 0.0,
                                      duration: (_isFirstPointer &&
                                              _isSecondPointer)
                                          ? const Duration(milliseconds: 800)
                                          : const Duration(milliseconds: 200),
                                      child: CustomAnimatedBuilder(
                                        value: !_isFirstPointer
                                            ? isLandscape
                                                ? 1.5
                                                : 2.0
                                            : 1.0,
                                        curve: Curves.decelerate,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        builder: (BuildContext context,
                                                Widget? child,
                                                Animation<dynamic> animation) =>
                                            Transform.scale(
                                          scale: animation.value,
                                          child: child,
                                        ),
                                        child: Text(
                                          _annotationValue2,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                              fontSize: _annotationFontSize,
                                              fontFamily: 'Times'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          angle: 90)
                    ]),
              ]),
            ),
            top: 0,
            left: 10,
            right: 10,
            bottom: 100,
          ),
          Positioned(
            child: Column(
              children: [Text("Tilting motor speed"), MotorSpeedControls()],
            ),
            bottom: 50,
            left: 0,
            right: 0,
          ),
          Positioned(child: Text("Tilt bounce angle", textAlign: TextAlign.center,), top: 5, right: 5, left: 5,),

        ],
      ),
    );
  }

  /// Dragged pointer new value is updated to pointer and
  /// annotation current value.
  void _handleSecondPointerValueChanged(double markerValue) {
    setState(() {
      _secondMarkerValue = markerValue.toInt().toDouble();
      final double value = _secondMarkerValue + (valueOffset);
      _annotationValue2 = 'B ${value}°';
    });
  }

  /// Pointer dragging is canceled when dragging pointer value is less than 6.
  void _handleSecondPointerValueChanging(ValueChangingArgs args) {}

  /// Value changed call back for first pointer
  void _handleFirstPointerValueChanged(double markerValue) {
    setState(() {
      _firstMarkerValue = markerValue.toInt().toDouble();
      final double value = _firstMarkerValue + (valueOffset);
      _annotationValue1 = 'A ${value}°';
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
class CustomAnimatedBuilder extends StatefulWidget {
  /// Creates a instance for [CustomAnimatedBuilder].
  const CustomAnimatedBuilder({
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
  _CustomAnimatedBuilderState createState() => _CustomAnimatedBuilderState();
}

class _CustomAnimatedBuilderState extends State<CustomAnimatedBuilder>
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
  void didUpdateWidget(CustomAnimatedBuilder oldWidget) {
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
