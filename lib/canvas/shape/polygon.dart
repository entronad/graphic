import 'dart:ui' show Offset, PaintingStyle, Path;

import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../util/in_stroke/polyline.dart' show inPolyline;

class Polygon extends Shape {
  Polygon(Cfg cfg) : super(cfg);

  @override
  bool isInStrokeOrPath(Offset refPoint, PaintingStyle style, double lineWidth) {
    final points = attrs.points;
    if (style == PaintingStyle.stroke) {
      return inPolyline(points, lineWidth, refPoint.dx, refPoint.dy, true);
    }
    final path = Path()..addPolygon(points, true);
    return path.contains(refPoint);
  }

  @override
  void createPath(Path path) {
    final points = attrs.points;
    path.addPolygon(points, true);
  }

  @override
  Polygon clone() => Polygon(cfg.clone());
}
