import 'package:drawing_robot_app/painter_size.dart';
import 'package:flutter/material.dart';

class A4Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.white;
    paint.strokeCap = StrokeCap.square;
    paint.strokeWidth = 1;
    canvas.drawRect(
      Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)),
      paint,
    );
    PainterSize().setSize([size.width, size.height]);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
