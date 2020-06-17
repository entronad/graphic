import 'dart:ui';

import 'package:graphic/src/engine/container.dart';
import 'package:graphic/src/engine/cfg.dart';
import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/engine/shape.dart' ;

import 'shape.dart' show ShapeBase, ShapeFactoryBase, ShapeCfg;
import '../base.dart';

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
