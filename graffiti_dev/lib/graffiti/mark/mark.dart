import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

abstract class Mark {
  void paint(Canvas canvas);
}

class Shadow {
  Shadow({
    required this.color,
    required this.elevation,
  });

  final Color color;

  final double elevation;

  static Shadow? lerp(Shadow? a, Shadow? b, double t) {
    if (a == null && b == null) {
      return null;
    } else {
      return Shadow(color: Color.lerp(a?.color, b?.color, t)!, elevation: lerpDouble(a?.elevation, b?.elevation, t)!);
    }
  }
}

abstract class Primitive extends Mark {
  Primitive({
    required this.style,
    this.shadow,
    this.dash,
  });

  final Paint style;

  final Shadow? shadow;

  final List<double>? dash;

  void createPath(Path path);

  @override
  void paint(Canvas canvas) {
    // The construction and destruction of path should be in the same place.
    final path = Path();
    createPath(path);

    if (shadow != null) {
      canvas.drawShadow(path, shadow!.color, shadow!.elevation, true);
    }

    if (dash == null) {
      canvas.drawPath(path, style);
    } else {
      canvas.drawPath(dashPath(path, dashArray: CircularIntervalList(dash!)), style);
    }
  }
}
