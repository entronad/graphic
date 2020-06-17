import 'dart:ui';

import 'package:graphic/src/engine/container.dart';
import 'package:graphic/src/engine/cfg.dart';
import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/engine/shape.dart' ;

import 'shape.dart' show ShapeBase, ShapeFactoryBase, ShapeCfg;
import '../base.dart';

List<double> _sortValue(List<double> value) {
  final sorted = [...value];
  sorted.sort((a, b) => a < b ? 1 : -1);

  final length = sorted.length;
  if (length < 4) {
    final min = sorted[length - 1];
    for (var i = 0; i < (4 - length); i++) {
      sorted.add(min);
    }
  }
  return sorted;
}

List<Offset> getCandlePoints(List<double> x, List<double> y, double width) {
  final yValues = _sortValue(y);
  final xValue = x.first;
  final points = [
    Offset(xValue, yValues[0]),
    Offset(xValue, yValues[1]),
    Offset(xValue - width / 2, yValues[2]),
    Offset(xValue - width / 2, yValues[1]),
    Offset(xValue + width / 2, yValues[1]),
    Offset(xValue + width / 2, yValues[2]),
    Offset(xValue, yValues[2]),
    Offset(xValue, yValues[3]),
  ];
  return points;
}

class SchemaFactory extends ShapeFactoryBase {
  @override
  GeomType get type => GeomType.schema;
}

class CanleShape extends ShapeBase {
  @override
  List<Offset> getPoints(ShapeCfg cfg) =>
    getCandlePoints(cfg.x, cfg.y, cfg.size);

  @override
  List<Shape> draw(ShapeCfg cfg, Container container) {
    final points = parsePoints(cfg.points.map((e) => e.first));
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    path.lineTo(points[1].dx, points[1].dy);
    path.moveTo(points[2].dx, points[2].dy);
    for (var i = 3; i < 6; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    path.moveTo(points[6].dx, points[6].dy);
    path.lineTo(points[7].dx, points[7].dy);
    final style = Attrs(
      color: cfg.color,
      strokeWidth: 1,
      path: path,
    ).mix(cfg.style);
    return [container.addShape(Cfg(
      type: 'custom',
      attrs: style,
    ))];
  }
}
