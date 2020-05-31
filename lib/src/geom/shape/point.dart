import 'dart:ui' show PaintingStyle;

import 'package:graphic/src/engine/container.dart' show Container;
import 'package:graphic/src/engine/cfg.dart' show Cfg;
import 'package:graphic/src/engine/attrs.dart' show Attrs;
import 'package:graphic/src/engine/shape.dart'  show Shape;

import 'shape.dart' show ShapeBase, ShapeFactoryBase;
import 'shape_cfg.dart' show ShapeCfg;
import '../geom_cfg.dart' show GeomType;

Attrs getPointsAttrs(ShapeCfg cfg) {
  final style = Attrs(
    strokeWidth: 0,
    color: cfg.color,
  );
  if (cfg.size != null) {
    style.r = cfg.size;
  }

  style.mix(cfg.style);
  return Attrs().mix(null).mix(style);    // TODO: global theme
}

List<Shape> drawShape(ShapeCfg cfg, Container container, String shape) {
  if (cfg.size == 0) {
    return null;
  }
  final pointAttrs = getPointsAttrs(cfg);
  final size = pointAttrs.r;
  final x = cfg.x;
  final y = cfg.y;
  if (shape == 'hollowCircle') {
    pointAttrs.strokeWidth = 1;
    pointAttrs.style = PaintingStyle.stroke;
  }
  if (shape == 'rect') {
    return [container.addShape(Cfg(
      type: 'rect',
      attrs: Attrs(
        x: x.first - size,
        y: y.first - size,
        width: size * 2,
        height: size * 2,
      ).mix(pointAttrs),
    ))];
  }

  return [container.addShape(Cfg(
    type: 'circle',
    attrs: Attrs(
      x: x.first,
      y: y.first,
      r: size,
    ).mix(pointAttrs),
  ))];
}

class PointFactory extends ShapeFactoryBase {
  @override
  GeomType get type => GeomType.point;

  @override
  String get defaultShapeType => 'circle';
}

class CircleShape extends ShapeBase {
  @override
  List<Shape> draw(ShapeCfg cfg, Container container) =>
    drawShape(cfg, container, 'circle');
}

class HollowCircleShape extends ShapeBase {
  @override
  List<Shape> draw(ShapeCfg cfg, Container container) =>
    drawShape(cfg, container, 'hollowCircle');
}

class RectShape extends ShapeBase {
  @override
  List<Shape> draw(ShapeCfg cfg, Container container) =>
    drawShape(cfg, container, 'rect');
}
