import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class RotatingCylinder extends StatelessWidget {
  final ValueNotifier<double> temperature;

  const RotatingCylinder({super.key, required this.temperature});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    final maxWidth = min(200.0, MediaQuery.of(context).size.width / 2 - 20);

    final maxContainedMercuryHeight = maxHeight - 60;
    final maxContainedMercuryWidth = maxWidth - 20;

    return SizedBox(
      height: maxHeight,
      width: maxWidth,
      child: Center(
        child: Container(
          height: maxContainedMercuryHeight,
          width: maxContainedMercuryWidth,
          decoration: ShapeDecoration(
            color: Colors.transparent,
            shape: const ContinuousRectangleBorder(),
          ),
          clipBehavior: Clip.antiAlias,
          child: ValueListenableBuilder(
            valueListenable: temperature,
            builder: (context, value, _) {
              return AnimatedMercuryPaintWidget(
                temperature: value,
              );
            },
          ),
        ),
      ),
    );
  }
}

class AnimatedMercuryPaintWidget extends StatefulWidget {
  final double temperature;

  const AnimatedMercuryPaintWidget({
    super.key,
    required this.temperature,
  });

  @override
  State<AnimatedMercuryPaintWidget> createState() =>
      _AnimatedMercuryPaintWidgetState();
}

class _AnimatedMercuryPaintWidgetState extends State<AnimatedMercuryPaintWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
  AnimationController(vsync: this, duration: const Duration(seconds: 1));
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CustomPaint(
          painter: MercuryPainter(
            animation: _animation.value,
            temperatureReduced: widget.temperature,
          ),
        );
      },
    );
  }
}

class MercuryPainter extends CustomPainter {
  final double temperatureReduced;
  final double animation;

  MercuryPainter({
    required this.animation,
    required this.temperatureReduced,
  });

  void paintOneWave(
      Canvas canvas,
      Size size, {
        required double temperatureHeight,
        required double cyclicAnimationValue,
        required List<double> colorStops,
        required List<Color> colors,
      }) {
    assert(colorStops.length == colors.length);

    Path path = Path();

    path.moveTo(0, temperatureHeight);

    for (double i = 0.0; i < size.width; i++) {
      path.lineTo(
        i,
        temperatureHeight +
            sin((i / size.width * 1 * pi) + (cyclicAnimationValue * 3 * pi)) *
                2,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    Paint paint = Paint();
    paint.shader = ui.Gradient.linear(
      const Offset(0, 0),
      Offset(0, size.height),
      colors,
      colorStops,
    );

    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final temperatureHeight = size.height - temperatureReduced * size.height;
    final paintColorStops = [0.0, 0.3, 0.7, 0.8, 0.95];

    paintOneWave(
      canvas,
      size,
      temperatureHeight: temperatureHeight,
      cyclicAnimationValue: (1 - animation),
      colorStops: paintColorStops,
      colors: [
        Colors.grey,
        Colors.grey,
        Colors.grey,
        Colors.grey,
        Colors.grey,
      ],
    );
    paintOneWave(
      canvas,
      size,
      temperatureHeight: temperatureHeight,
      cyclicAnimationValue: animation,
      colorStops: paintColorStops,
      colors: [
        Colors.grey.shade400,
        Colors.grey.shade400,
        Colors.grey.shade400,
        Colors.grey.shade400,
        Colors.grey.shade400,
      ],
    );
  }

  @override
  bool shouldRepaint(MercuryPainter oldDelegate) =>
      animation != oldDelegate.animation ||
          temperatureReduced != oldDelegate.temperatureReduced;

  @override
  bool shouldRebuildSemantics(MercuryPainter oldDelegate) => false;
}
