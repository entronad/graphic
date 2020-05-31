import 'dart:ui' show Offset;

import 'package:graphic/src/engine/container.dart' show Container;
import 'package:graphic/src/engine/cfg.dart' show Cfg;
import 'package:graphic/src/engine/attrs.dart' show Attrs;
import 'package:graphic/src/engine/shape.dart'  show Shape;

import 'shape.dart' show ShapeBase, ShapeFactoryBase;
import 'shape_cfg.dart' show ShapeCfg;
import '../geom_cfg.dart' show GeomType;

class PolygonFactory extends ShapeFactoryBase {
  @override
  GeomType get type => GeomType.polygon;

  @override
  String get defaultShapeType => 'polygon';

  @override
  List<Offset> getDefaultPoints(ShapeCfg cfg) {
    final points = <Offset>[];
    final x = cfg.x;
    final y = cfg.y;
    for (var i = 0; i < x.length; i++) {
      points.add(Offset(x[i], y[i]));
    }
    return points;
  }
}

class PolygonShape extends ShapeBase {
  @override
  List<Shape> draw(ShapeCfg cfg, Container container) {
    final points = parsePoints(cfg.points.map((e) => e.first));
    final style = Attrs(
      color: cfg.color,
      points: points
    ).mix(cfg.style);
    return [container.addShape(Cfg(
      type: 'polygon',
      attrs: style,
    ))];
  }
}
