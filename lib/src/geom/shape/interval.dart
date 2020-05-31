import 'dart:ui' show Offset;
import 'dart:math' show min, max, pi;

import 'package:graphic/src/engine/container.dart' show Container;
import 'package:graphic/src/engine/cfg.dart' show Cfg;
import 'package:graphic/src/engine/attrs.dart' show Attrs;
import 'package:graphic/src/engine/shape.dart'  show Shape;
import 'package:graphic/src/engine/util/vector2.dart' show Vector2;

import 'shape.dart' show ShapeBase, ShapeFactoryBase;
import 'shape_cfg.dart' show ShapeCfg;
import '../geom_cfg.dart' show GeomType;

List<Offset> getRectPoints(ShapeCfg cfg) {
  final x = cfg.x;
  final y = cfg.y;
  final y0 = cfg.y0;
  final size = cfg.size;

  final ymin = y.length > 1 ? y.first : y0;
  final ymax = y.last;

  double xmin;
  double xmax;
  if (x.length > 1) {
    xmin = x.first;
    xmax = x.last;
  } else {
    xmin = x.first - size / 2;
    xmax = x.first - size / 2;
  }

  return [
    Offset(xmin, ymin),
    Offset(xmin, ymax),
    Offset(xmax, ymax),
    Offset(xmax, ymin),
  ];
}

Attrs getRectRange(List<Offset> points) {
  final xValues = <double>[];
  final yValues = <double>[];
  for (var point in points) {
    xValues.add(point.dx);
    yValues.add(point.dy);
  }
  final xMin = xValues.reduce(min);
  final yMin = yValues.reduce(min);
  final xMax = xValues.reduce(max);
  final yMax = yValues.reduce(max);

  return Attrs(
    x: xMin,
    y: yMin,
    width: xMax - xMin,
    height: yMax - yMin,
  );
}

List<Offset> getPolygonPoints(ShapeCfg cfg) {
  cfg.size = cfg.size * 2;
  return getRectPoints(cfg);
}

List<Shape> drawPolygon(ShapeCfg cfg, Container container, ShapeBase self, String shapeType) {
  final points = self.parsePoints(cfg.points.map((e) => e.first));
  final nextPoints = self.parsePoints(cfg.nextPoints);

  List<Offset> polygonPoints;
  if (nextPoints != null) {
    polygonPoints = [points[0], points[1], nextPoints[1], nextPoints[0]];
  } else {
    polygonPoints = [points[0], points[1]];
    if (shapeType == 'pyramid') {
      polygonPoints.add(Offset.lerp(points[2], points[3], 0.5));
    } else {
      polygonPoints.add(points[2]);
      polygonPoints.add(points[3]);
    }
  }

  final attrs = Attrs(
    color: cfg.color,
    points: polygonPoints,
  )
    ..mix(null)    // TODO: global theme
    ..mix(cfg.style);
  
  return [container.addShape(Cfg(
    type: 'polygon',
    attrs: attrs,
  ))];
}

class IntervalFactory extends ShapeFactoryBase {
  @override
  GeomType get type => GeomType.interval;

  @override
  String get defaultShapeType => 'rect';

  @override
  List<Offset> getDefaultPoints(ShapeCfg cfg) =>
    getRectPoints(cfg);
}

class RectShape extends ShapeBase {
  @override
  List<Shape> draw(ShapeCfg cfg, Container container) {
    final points = parsePoints(cfg.points.map((e) => e.first));
    final style = Attrs(color: cfg.color)
      ..mix(null) // TODO: global theme
      ..mix(cfg.style);
    if (cfg.isInCircle) {
      var newPoints = [...points];
      if (coord.cfg.transposed) {
        newPoints = [points[0], points[1], points[2], points[1]];
      }

      final x = cfg.center.dx;
      final y = cfg.center.dy;
      final v = Vector2(1, 0);
      final v0 = Vector2(newPoints[0].dx, newPoints[0].dy);
      final v1 = Vector2(newPoints[1].dx, newPoints[1].dy);
      final v2 = Vector2(newPoints[2].dx, newPoints[2].dy);

      var startAngle = v.angleTo(v1);
      var endAngle = v.angleTo(v2);
      final r0 = v0.length;
      final r = v1.length;

      if (startAngle >= 1.5 * pi) {
        startAngle = startAngle - 2 * pi;
      }

      if (endAngle >= 1.5 * pi) {
        endAngle = endAngle - 2 * pi;
      }

      return [container.addShape(Cfg(
        type: 'sector',
        attrs: Attrs(
          x: x,
          y: y,
          r: r,
          r0: r0,
          startAngle: startAngle,
          endAngle: endAngle,
        ).mix(style),
      ))];
    }

    final rectAttrs = getRectRange(points);

    return [container.addShape(Cfg(
      type: 'rect',
      attrs: rectAttrs.mix(style),
    ))];
  }
}

class PyramidShape extends ShapeBase {
  @override
  List<Offset> getPoints(ShapeCfg cfg) =>
    getPolygonPoints(cfg);

  @override
  List<Shape> draw(ShapeCfg cfg, Container container) =>
    drawPolygon(cfg, container, this, 'pyramid');
}

class FunnelShape extends ShapeBase {
  @override
  List<Offset> getPoints(ShapeCfg cfg) =>
    getPolygonPoints(cfg);

  @override
  List<Shape> draw(ShapeCfg cfg, Container container) =>
    drawPolygon(cfg, container, this, 'funnel');
}
