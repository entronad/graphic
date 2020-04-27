import 'dart:ui' show Offset, PaintingStyle, Path;

import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;
import '../util/in_stroke/line.dart' show inLine;
import '../math/line.dart' show length;

class Line extends Shape {
  Line(Cfg cfg) : super(cfg);

  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x1 = 0
    ..y1 = 0
    ..x2 = 0
    ..y2 = 0;

  @override
  bool isInStrokeOrPath(Offset refPoint, PaintingStyle style, double lineWidth) {
    if (!(style == PaintingStyle.stroke) || lineWidth <= 0) {
      return false;
    }
    final x1 = attrs.x1;
    final y1 = attrs.y1;
    final x2 = attrs.x2;
    final y2 = attrs.y2;
    return inLine(x1, y1, x2, y2, lineWidth, refPoint.dx, refPoint.dy);
  }

  @override
  void createPath(Path path) {
    final x1 = attrs.x1;
    final y1 = attrs.y1;
    final x2 = attrs.x2;
    final y2 = attrs.y2;

    path.moveTo(x1, y1);
    path.lineTo(x2, y2);
  }

  @override
  double get totalLength {
    final x1 = attrs.x1;
    final y1 = attrs.y1;
    final x2 = attrs.x2;
    final y2 = attrs.y2;
    return length(x1, y1, x2, y2);
  }

  @override
  Offset getPoint(double ratio) {
    final p1 = Offset(attrs.x1, attrs.y1);
    final p2 = Offset(attrs.x2, attrs.y2);
    return Offset.lerp(p1, p2, ratio);
  }

  @override
  Line clone() => Line(cfg.clone());
}
