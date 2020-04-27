import 'dart:ui' show Offset, PaintingStyle, Path;

import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../util/in_stroke/polyline.dart' show inPolyline;
import '../math/polyline.dart' as polyline_util show length;
import '../math/line.dart' as line_util show length;

class Polyline extends Shape {
  Polyline(Cfg cfg) : super(cfg);

  @override
  void onAttrChange(String name, Object value, Object originValue) {
    super.onAttrChange(name, value, originValue);
    if (name == 'points') {
      _resetCache();
    }
  }

  void _resetCache() {
    cfg.totalLength = null;
    cfg.tChache = null;
  }

  @override
  PaintingStyle get paintingStyle => PaintingStyle.stroke;

  @override
  bool isInStrokeOrPath(Offset refPoint, PaintingStyle style, double lineWidth) {
    if (!(style == PaintingStyle.stroke) || lineWidth <= 0) {
      return false;
    }
    final points = attrs.points;
    return inPolyline(points, lineWidth, refPoint.dx, refPoint.dy, false);
  }

  @override
  void createPath(Path path) {
    final points = attrs.points;
    final length = points.length;
    if (length < 2) {
      return;
    }
    
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
  }

  @override
  double get totalLength {
    final totalLength = cfg.totalLength;
    if (totalLength != null) {
      return totalLength;
    }
    final points = attrs.points;
    cfg.totalLength = polyline_util.length(points);
    return cfg.totalLength;
  }

  @override
  Offset getPoint(double ratio) {
    final points = attrs.points;
    var tCache = cfg.tChache;
    if (tCache == null) {
      _setTCache();
      tCache = cfg.tChache;
    }

    double subT;
    int index;
    for (var i = 0; i < tCache.length; i++) {
      // v: [startRatio, endRatio]
      final v = tCache[i];
      if (ratio >= v[0] && ratio <= v[1]) {
        subT = (ratio - v[0]) / (v[1] - v[0]);
        index = i;
      }
    }
    return Offset.lerp(points[index], points[index + 1], subT);
  }

  void _setTCache() {
    final points = attrs.points;
    final length = points.length;
    if (length < 2) {
      return;
    }

    final totalLength = this.totalLength;
    if (totalLength <= 0) {
      return;
    }

    var tempLength = 0.0;
    final tCache = <List<double>>[];
    List<double> segmentT;
    double segmentL;
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      segmentT = [];
      segmentT[0] = tempLength / totalLength;
      segmentL = line_util.length(p.dx, p.dy, points[i + 1].dx, points[i + 1].dy);
      tempLength += segmentL;
      segmentT[1] = tempLength / totalLength;
      tCache.add(segmentT);
    }
  }

  @override
  Polyline clone() => Polyline(cfg.clone());
}
