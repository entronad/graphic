import 'dart:ui' show Offset;

import 'package:graphic/src/engine/container.dart' show Container;
import 'package:graphic/src/engine/cfg.dart' show Cfg;
import 'package:graphic/src/engine/attrs.dart' show Attrs;
import 'package:graphic/src/engine/shape.dart'  show Shape;

import 'shape.dart' show ShapeBase, ShapeFactoryBase;
import 'shape_cfg.dart' show ShapeCfg;
import '../geom_cfg.dart' show GeomType;

Attrs getStyle(ShapeCfg cfg) {
  final style = Attrs(
    color: cfg.color,
  );
  if (cfg.size != null && cfg.size >= 0) {
    style.strokeWidth = cfg.size;
  }
  style.mix(cfg.style);

  return Attrs().mix(null).mix(style);   // TODO: global theme
}

List<Shape> drawLines(
  ShapeCfg cfg,
  Container container,
  Attrs style,
  bool smooth,
) {
  final points = cfg.points;
  if (points.first.length > 1) {
    List<Offset> topPoints = [];
    List<Offset> bottomPoints = [];
    for (var point in points) {
      bottomPoints.add(point.first);
      topPoints.add(point.last);
    }
    if (cfg.isInCircle) {
      bottomPoints.add(bottomPoints.first);
      topPoints.add(topPoints.first);
    }
    if (cfg.isStack) {
      return [container.addShape(Cfg(
        type: 'polyline',
        attrs: Attrs(
          points: topPoints,
          smooth: smooth,
        ).mix(style),
      ))];
    }
    final topShape = container.addShape(Cfg(
      type: 'polyline',
      attrs: Attrs(
        points: topPoints,
        smooth: smooth,
      ).mix(style),
    ));
    final bottomShape = container.addShape(Cfg(
      type: 'polyline',
      attrs: Attrs(
        points: bottomPoints,
        smooth: smooth,
      ).mix(style),
    ));

    return [topShape, bottomShape];
  }
  if (cfg.isInCircle) {
    points.add(points.first);
  }
  return [container.addShape(Cfg(
    type: 'polyline',
    attrs: Attrs(
      points: points.map((e) => e.first),
      smooth: smooth,
    ).mix(style),
  ))];
}

class LineFactory extends ShapeFactoryBase {
  @override
  GeomType get type => GeomType.line;

  @override
  String get defaultShapeType => 'line';
}

class LineShape extends ShapeBase {
  @override
  List<Shape> draw(ShapeCfg cfg, Container container) {
    final style = getStyle(cfg);
    return drawLines(cfg, container, style, false);
  }
}

class SmoothShape extends ShapeBase {
  @override
  List<Shape> draw(ShapeCfg cfg, Container container) {
    final style = getStyle(cfg);
    return drawLines(cfg, container, style, true);
  }
}
