import 'dart:ui' show Offset, PaintingStyle, Path, Rect;

import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;

double ovalDistance(double squareX, double squareY, double rx, double ry) {
  return squareX / (rx * rx) + squareY / (ry * ry);
}

class Oval extends Shape {
  Oval(Cfg cfg) : super(cfg);

  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x = 0
    ..y = 0
    ..rx = 0
    ..ry = 0;

  @override
  bool isInStrokeOrPath(Offset refPoint, PaintingStyle style, double lineWidth) {
    final cx = attrs.x;
    final cy = attrs.y;
    final rx = attrs.rx;
    final ry = attrs.ry;
    final squareX = (refPoint.dx - cx) * (refPoint.dx - cx);
    final squareY = (refPoint.dy - cy) * (refPoint.dy - cy);
    if (style == PaintingStyle.stroke) {
      final halfLineWidth = lineWidth / 2;
      return (
        ovalDistance(squareX, squareY, rx - halfLineWidth, ry - halfLineWidth) >= 1
          && ovalDistance(squareX, squareY, rx + halfLineWidth, ry + halfLineWidth) <= 1
      );
    }
    return ovalDistance(squareX, squareY, rx, ry) <= 1;
  }

  @override
  void createPath(Path path) {
    final cx = attrs.x;
    final cy = attrs.y;
    final rx = attrs.rx;
    final ry = attrs.ry;
    path.addOval(Rect.fromCenter(
      center: Offset(cx, cy),
      width: 2 * rx,
      height: 2 * ry,
    ));
  }

  @override
  Oval clone() => Oval(cfg.clone());
}
