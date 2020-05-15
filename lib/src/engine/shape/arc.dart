import 'dart:math' show pi;
import 'dart:ui' show Path, Rect, Offset;

import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;
import '../shape.dart' show Shape;

class Arc extends Shape {
  Arc(Cfg cfg) : super(cfg);

  @override
  Cfg get defaultCfg => super.defaultCfg
    ..type = 'arc';
  
  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x = 0
    ..y = 0
    ..r = 0
    ..startAngle = 0
    ..endAngle = 2 * pi
    ..clockwise = true
    ..strokeWidth = 1;
  
  @override
  void createPath(Path path) {
    final x = attrs.x;
    final y = attrs.y;
    final r = attrs.r;
    final startAngle = attrs.startAngle;
    final endAngle = attrs.endAngle;
    final clockwise = attrs.clockwise;

    final sweepAngle = clockwise ? endAngle - startAngle : startAngle - endAngle;
    path.addArc(
      Rect.fromCircle(center: Offset(x, y), radius: r),
      startAngle,
      sweepAngle,
    );
  }
}
