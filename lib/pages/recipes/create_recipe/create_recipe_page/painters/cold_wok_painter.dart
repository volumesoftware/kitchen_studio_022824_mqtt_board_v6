import 'package:flutter/material.dart';

class ColdWokPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..quadraticBezierTo(
          size.width * 0.6, size.height * 0.25, size.width * 0.9, size.height * 0.4)
      ..quadraticBezierTo(
          size.width * 0.7, size.height * 0.5, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(
          size.width * 0.3, size.height * 0.5, size.width * 0.1, size.height * 0.4)
      ..quadraticBezierTo(
          size.width * 0.4, size.height * 0.25, size.width * 0.5, size.height * 0.1);

    canvas.drawPath(path, paint);



  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}