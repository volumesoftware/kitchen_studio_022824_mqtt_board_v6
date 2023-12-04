
import 'package:flutter/material.dart';

class HotWashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.3)
      ..lineTo(size.width * 0.2, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.15, size.width * 0.2, size.height * 0.3);

    canvas.drawPath(path, paint);

    final bubblesPaint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.45), 5, bubblesPaint);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.5), 5, bubblesPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 5, bubblesPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.45), 5, bubblesPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.5), 5, bubblesPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}