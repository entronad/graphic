import 'dart:ui' show Offset, PaintingStyle, Path, Rect;

import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;
import '../math/util.dart' show distance;

class Circle extends Shape {
  Circle(Cfg cfg) : super(cfg);

  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x = 0
    ..y = 0
    ..r = 0;

  @override
  bool isInStrokeOrPath(Offset refPoint, PaintingStyle style, double lineWidth) {
    final cx = attrs.x;
    final cy = attrs.y;
    final r = attrs.r;
    final absDistance = distance(refPoint.dx - cx, refPoint.dy - cy);
    if (style == PaintingStyle.stroke) {
      final halfLineWidth = lineWidth / 2;
      return absDistance >= r - halfLineWidth && absDistance <= r + halfLineWidth;
    }
    return absDistance <= r;
  }

  @override
  void createPath(Path path) {
    final cx = attrs.x;
    final cy = attrs.y;
    final r = attrs.r;
    path.addOval(Rect.fromCenter(
      center: Offset(cx, cy),
      width: 2 * r,
      height: 2 * r,
    ));
  }

  @override
  Circle clone() => Circle(cfg.clone());
}
