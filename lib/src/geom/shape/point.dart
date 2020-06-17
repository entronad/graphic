import 'dart:ui';

import 'package:graphic/src/engine/container.dart';
import 'package:graphic/src/engine/cfg.dart';
import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/engine/shape.dart' ;
import 'package:graphic/src/global.dart';

import 'shape.dart' show ShapeBase, ShapeFactoryBase, ShapeCfg;
import '../base.dart';

Attrs getPointsAttrs(ShapeCfg cfg) {
  final style = Attrs(
    strokeWidth: 0,
    color: cfg.color,
  );
  if (cfg.size != null) {
    style.r = cfg.size;
  }

  style.mix(cfg.style);
  return Attrs().mix(Global.theme.shape[GeomType.point]).mix(style);
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
