import 'dart:ui' show Offset, PaintingStyle, Path, RRect, Radius;

import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;

class Rect extends Shape {
  Rect(Cfg cfg) : super(cfg);

  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x = 0
    ..y = 0
    ..width = 0
    ..height = 0
    ..r = 0;

  @override
  bool isInStrokeOrPath(Offset refPoint, PaintingStyle style, double lineWidth) {
    final left = attrs.x;
    final top = attrs.y;
    final width = attrs.width;
    final height = attrs.height;
    final r = attrs.r;
    final rrect = RRect.fromLTRBR(
      left,
      top,
      left + width,
      top + height,
      Radius.circular(r)
    );
    if (style == PaintingStyle.stroke) {
      final halfWidth = lineWidth / 2;
      return rrect.inflate(halfWidth).contains(refPoint)
        || !rrect.deflate(halfWidth).contains(refPoint);
    }
    return rrect.contains(refPoint);
  }

  @override
  void createPath(Path path) {
    final left = attrs.x;
    final top = attrs.y;
    final width = attrs.width;
    final height = attrs.height;
    final r = attrs.r;
    final rrect = RRect.fromLTRBR(
      left,
      top,
      left + width,
      top + height,
      Radius.circular(r)
    );
    path.addRRect(rrect);
  }

  @override
  Rect clone() => Rect(cfg.clone());
}
