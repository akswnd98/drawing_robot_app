import 'package:drawing_robot_app/point_paths_utils.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PathPainter extends CustomPainter {
  List<List<List<double>>> pointPaths;
  List<double> bbox;

  PathPainter(
    this.pointPaths,
    this.bbox,
  ) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black;
    paint.strokeCap = StrokeCap.square;
    paint.strokeWidth = 1;

    canvas.save();
    canvas.scale(1, 1);

    for (List<List<double>> path in pointPaths) {
      for (var i = 0; i < path.length - 1; i++) {
        canvas.drawLine(
          Offset(path[i][0], path[i][1]),
          Offset(path[i + 1][0], path[i + 1][1]),
          paint,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
