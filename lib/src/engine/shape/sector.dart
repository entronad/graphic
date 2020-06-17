import 'dart:math';
import 'dart:ui';

import '../cfg.dart';
import '../attrs.dart';
import '../shape.dart';

class Sector extends Shape {
  Sector(Cfg cfg) : super(cfg);

  @override
  Cfg get defaultCfg => super.defaultCfg
    ..type = 'sector';
  
  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x = 0
    ..y = 0
    ..r = 0
    ..r0 = 0
    ..startAngle = 0
    ..endAngle = 2 * pi
    ..clockwise = true
    ..strokeWidth = 0;
  
  @override
  void createPath(Path path) {
    final x = attrs.x;
    final y = attrs.y;
    final r = attrs.r;
    final r0 = attrs.r0;
    final startAngle = attrs.startAngle;
    final endAngle = attrs.endAngle;
    final clockwise = attrs.clockwise;

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
  }
}
