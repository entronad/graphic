import 'dart:ui';

import 'package:graphic/src/engine/container.dart';
import 'package:graphic/src/engine/cfg.dart';
import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/engine/shape.dart' ;
import 'package:graphic/src/engine/util/smooth.dart' as smooth_util;
import 'package:graphic/src/global.dart';

import 'shape.dart' show ShapeBase, ShapeFactoryBase, ShapeCfg;
import '../base.dart';

bool equals(num v1, num v2) =>
  (v1 - v2).abs() < 0.00001;

bool notEmpty(num value) =>
  (value != null) && !value.isNaN;

List<Offset> filterPoints(List<Offset> points) {
  final filteredPoints = <Offset>[];
  for (var point in points) {
    if (notEmpty(point.dx) && notEmpty(point.dy)) {
      filteredPoints.add(point);
    }
  }

  return filteredPoints;
}

bool equalsCenter(List<Offset> points, Offset center) {
  var eqls = true;
  for (var point in points) {
    if (!equals(point.dx, center.dx) || !equals(point.dy, center.dy)) {
      eqls = false;
      return false;
    }
  }
  return eqls;
}

Path createSmoothAreaPath(List<Offset> points) {
  final constraint = Rect.fromLTWH(0, 0, 1, 1);
  final pointsLen = points.length;
  final topPoints = points.sublist(0, pointsLen ~/ 2);
  final bottomPoints = points.sublist(pointsLen ~/ 2, pointsLen);
  final topSps = smooth_util.smooth(topPoints, false, constraint);
  final path = Path();
  path.moveTo(topPoints[0].dx, topPoints[0].dy);
  for (var sp in topSps) {
    path.cubicTo(sp.cp1.dx, sp.cp1.dy, sp.cp2.dx, sp.cp2.dy, sp.p.dx, sp.p.dy);
  }

  if (bottomPoints.isNotEmpty) {
    final bottomSps = smooth_util.smooth(bottomPoints, false, constraint);
    path.moveTo(bottomPoints[0].dx, bottomPoints[0].dy);
    for (var sp in bottomSps) {
      path.cubicTo(sp.cp1.dx, sp.cp1.dy, sp.cp2.dx, sp.cp2.dy, sp.p.dx, sp.p.dy);
    }
  }
  path.close();
  return path;
}

List<Shape> drawRectShape(
  List<Offset> topPoints,
  List<Offset> bottomPoints,
  Container container,
  Attrs style,
  bool isSmooth,
) {
  Shape shape;
  final points = [...topPoints, ...bottomPoints];
  if (isSmooth) {
    shape = container.addShape(Cfg(
      type: 'custom',
      attrs: Attrs(
        path: createSmoothAreaPath(points),
      ).mix(style),
    ));
  } else {
    shape = container.addShape(Cfg(
      type: 'polyline',
      attrs: Attrs(
        points: points,
      ).mix(style),
    ));
  }
  return [shape];
}

List<Shape> drawShape(ShapeCfg cfg, Container container, bool isSmooth, ShapeBase self) {
  final points = cfg.points;
  List<Offset> topPoints = [];
  List<Offset> bottomPoints = [];
  for (var point in points) {
    bottomPoints.add(point.first);
    topPoints.add(point.last);
  }
  final style = Attrs(color: cfg.color)
    .mix(Global.theme.shape[GeomType.area])
    .mix(cfg.style);

  bottomPoints = bottomPoints.reversed;
  topPoints = self.parsePoints(topPoints);
  bottomPoints = self.parsePoints(bottomPoints);
  if (cfg.isInCircle) {
    topPoints.add(topPoints[0]);
    bottomPoints.insert(0, bottomPoints.last);
    if (equalsCenter(bottomPoints, cfg.center)) {
      bottomPoints = [];
    }
  }

  return drawRectShape(topPoints, bottomPoints, container, style, isSmooth);
}

class AreaFactory extends ShapeFactoryBase  {
  @override
  GeomType get type => GeomType.area;
  
  @override
  String get defaultShapeType => 'area';

  @override
  List<Offset> getDefaultPoints(ShapeCfg cfg) {
    final x = cfg.x.first;
    final y = cfg.y.length > 1 ? cfg.y : [cfg.y0, cfg.y.last];

    final points = [];
    points.add(Offset(x, y.first));
    points.add(Offset(x, y.last));
    return points;
  }
}

class AreaShape extends ShapeBase {
  @override
  List<Shape> draw(ShapeCfg cfg, Container container) =>
    drawShape(cfg, container, false, this);
}

class SmoothShape extends ShapeBase {
  @override
  List<Shape> draw(ShapeCfg cfg, Container container) =>
    drawShape(cfg, container, true, this);
}
