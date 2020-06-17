import 'dart:ui';

import '../cfg.dart';
import '../attrs.dart';
import '../shape.dart';
import '../util/smooth.dart' as smooth_util;

List<Offset> _filterPoints(List<Offset> points) {
  final filteredPoints = <Offset>[];
  for (var point in points) {
    if (
      point.dx != null && point.dx.isFinite &&
      point.dy != null && point.dy.isFinite
    ) {
      filteredPoints.add(point);
    }
  }
  return filteredPoints;
}

class Polyline extends Shape {
  Polyline(Cfg cfg) : super(cfg);

  @override
  Cfg get defaultCfg => super.defaultCfg
    ..type = 'polyline';
  
  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..smooth = false
    ..strokeWidth = 1;
  
  @override
  void createPath(Path path) {
    final points = attrs.points;
    final smooth = attrs.smooth;

    final filteredPoints = _filterPoints(points);

    if (filteredPoints.length > 0) {
      path.moveTo(filteredPoints[0].dx, filteredPoints[0].dy);
      if (smooth) {
        final constraint = Rect.fromLTWH(0, 0, 1, 1);
        final sps = smooth_util.smooth(filteredPoints, false, constraint);
        for (var sp in sps) {
          path.cubicTo(sp.cp1.dx, sp.cp1.dy, sp.cp2.dx, sp.cp2.dy, sp.p.dx, sp.p.dy);
        }
      } else {
        final l = filteredPoints.length - 1;
        for (var i = 1; i < l; i++) {
          path.lineTo(filteredPoints[i].dx, filteredPoints[i].dy);
        }
        path.lineTo(filteredPoints[l].dx, filteredPoints[l].dy);
      }
    }
  }
}
