import 'dart:math';
import 'dart:ui';
import 'smooth.dart' as smooth_util;

abstract class Paths {
  static Path arc({
    required double x,
    required double y,
    required double r,
    required startAngle,
    required endAngle,
    required clockwise,
    Path? path,
  }) => (path ?? Path())..addArc(
    Rect.fromCircle(center: Offset(x, y), radius: r),
    startAngle,
    clockwise ? endAngle - startAngle : startAngle - endAngle,
  );

  static Path polyline({
    required List<Offset> points,
    required bool smooth,
    Path? path,
  }) {
    path = path ?? Path();

    path.moveTo(points[0].dx, points[0].dy);
    if (smooth) {
      final segments = smooth_util.smooth(points, false, true);
      for (var s in segments) {
        path.cubicTo(s.cp1.dx, s.cp1.dy, s.cp2.dx, s.cp2.dy, s.p.dx, s.p.dy);
      }
    } else {
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    return path;
  }

  static Path sector({
    required Offset center,
    required double r,
    required double r0,
    required double startAngle,
    required double endAngle,
    required bool clockwise,
    Path? path,
  }) {
    path = path ?? Path();

    final sweepAngle = clockwise ? endAngle - startAngle : startAngle - endAngle;

    path.moveTo(cos(startAngle) * r + center.dx, sin(startAngle) * r + center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: r),
      startAngle,
      sweepAngle,
      false,
    );
    path.lineTo(cos(endAngle) * r0 + center.dx, sin(endAngle) * r0 + center.dy);
    if (r0 != 0) {
      path.arcTo(
        Rect.fromCircle(center: center, radius: r0),
        endAngle,
        -sweepAngle,
        false,
      );
    }
    path.close();

    return path;
  }

  static Path rsector({
    required Offset center,
    required double r,
    required double r0,
    required double startAngle,
    required double endAngle,
    required bool clockwise,
    required Radius topLeft,
    required Radius topRight,
    required Radius bottomRight,
    required Radius bottomLeft,
    Path? path,
  }) {
    path = path ?? Path();

    double arcStart;
    double arcEnd;
    double arcSweep;
    
    // top
    path.moveTo(
      cos(startAngle) * (r - topLeft.y) + center.dx,
      sin(startAngle) * (r - topLeft.y) + center.dy,
    );
    arcStart = clockwise ? startAngle + (topLeft.x / r) : startAngle - (topLeft.x / r);
    arcEnd = clockwise ? endAngle + (topRight.x / r) : endAngle - (topRight.x / r);
    arcSweep = clockwise ? arcEnd - arcStart : arcStart - arcEnd;
    // top left
    path.quadraticBezierTo(
      cos(startAngle) * r + center.dx,
      sin(startAngle) * r + center.dy,
      cos(arcStart) * r + center.dx,
      sin(arcStart) * r + center.dy,
    );
    // top arc
    path.arcTo(
      Rect.fromCircle(center: center, radius: r),
      arcStart,
      arcSweep,
      false,
    );
    // top right
    path.quadraticBezierTo(
      cos(endAngle) * r + center.dx,
      sin(endAngle) * r + center.dy,
      cos(endAngle) * (r - topRight.y) + center.dx,
      sin(endAngle) * (r - topRight.y) + center.dy,
    );
    // bottom
    path.lineTo(
      cos(endAngle) * (r0 + bottomRight.y) + center.dx,
      sin(endAngle) * (r0 + bottomRight.y) + center.dy,
    );
    if (r0 != 0) {
      arcStart = clockwise ? startAngle + (bottomLeft.x / r) : startAngle - (bottomLeft.x / r);
      arcEnd = clockwise ? endAngle + (bottomRight.x / r) : endAngle - (bottomRight.x / r);
      arcSweep = clockwise ? arcEnd - arcStart : arcStart - arcEnd;
      // bottom right
      path.quadraticBezierTo(
        cos(endAngle) * r0 + center.dx,
        sin(endAngle) * r0 + center.dy,
        cos(arcEnd) * r0 + center.dx,
        sin(arcEnd) * r0 + center.dy,
      );
      // bottom arc
      path.arcTo(
        Rect.fromCircle(center: center, radius: r0),
        arcEnd,
        -arcSweep,
        false,
      );
      // bottom left
      path.quadraticBezierTo(
        cos(startAngle) * r0 + center.dx,
        sin(startAngle) * r0 + center.dy,
        cos(startAngle) * (r0 + bottomLeft.y) + center.dx,
        sin(startAngle) * (r0 + bottomLeft.y) + center.dy,
      );
    }
    path.close();

    return path;
  }
}
