import 'dart:math';
import 'dart:ui';

enum Interpolate {
  basis,
  bundle,
  cardinal,
  catmullRom,
  linear,
  monotone,
  natural,
  step,
  stepAfter,
  stepBefore,
}

abstract class Paths {
  static Path arc({
    required double x,
    required double y,
    required double r,
    required startAngle,
    required endAngle,
    required clockwise,
  }) => Path()..addArc(
    Rect.fromCircle(center: Offset(x, y), radius: r),
    startAngle,
    clockwise ? endAngle - startAngle : startAngle - endAngle,
  );

  static Path circle({
    required double x,
    required double y,
    required double r,
  }) => Path()..addOval(
    Rect.fromCircle(center: Offset(x, y), radius: r)
  );

  static Path line({
    required double x1,
    required double y1,
    required double x2,
    required double y2,
  }) => Path()
    ..moveTo(x1, y1)
    ..lineTo(x2, y2);
  
  static Path polygon({
    required List<Offset> points,
  }) {
    final path = Path();

    if (points.isEmpty) {
      return path;
    }

    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      path.lineTo(point.dx, point.dy);
    }
    path.close();

    return path;
  }

  static Path polyline({
    required List<Offset> points,
    required Interpolate interpolate,
    required double tension,
  }) {
    return Path();
  }

  static Path rect({
    required double x,
    required double y,
    required double width,
    required double height,
    required Radius radius,
  }) => Path()..addRRect(RRect.fromLTRBR(
    x,
    y,
    x + width,
    y + height,
    radius,
  ));

  static Path sector({
    required double x,
    required double y,
    required double r,
    required double r0,
    required double startAngle,
    required double endAngle,
    required bool clockwise,
  }) {
    final path = Path();

    final sweepAngle = clockwise ? endAngle - startAngle : startAngle - endAngle;
    final unitX = cos(startAngle);
    final unitY = sin(startAngle);

    path.moveTo(unitX * r0 + x, unitY * r0 + y);
    path.lineTo(unitX * r + x, unitY * r + y);
    if (sweepAngle.abs() > 0.0001 || startAngle == 0 && endAngle < 0) {
      path.arcTo(
        Rect.fromCircle(center: Offset(x, y), radius: r),
        startAngle,
        sweepAngle,
        false,
      );
      path.lineTo(cos(endAngle) * r0 + x, sin(endAngle) * r0 + y);
      if (r0 != 0) {
        path.arcTo(
          Rect.fromCircle(center: Offset(x, y), radius: r0),
          endAngle,
          -sweepAngle,
          false,
        );
      }
    }
    path.close();

    return path;
  }
}
