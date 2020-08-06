import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/polygon.dart';

import '../base.dart';

double _normalize(double value, double bias) =>
  (value + bias) / (1 + bias * 2);

List<RenderShape> mosaicPolygon(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) {
  var stepX = double.infinity;
  var stepY = double.infinity;
  for (var i = 0; i < attrValueRecords.length - 1; i++) {
    final point = attrValueRecords[i].position.first;
    final nextPoint = attrValueRecords[i].position.first;
    stepX = min(stepX, (nextPoint.dx - point.dx).abs());
    stepY = min(stepY, (nextPoint.dy - point.dy).abs());
  }
  final biasX = stepX / 2;
  final biasY = stepY / 2;

  final rst = <RenderShape>[];

  for (var record in attrValueRecords) {
    final point = record.position.first;
    final color = record.color;

    var abstractPoints = [
      Offset(point.dx - biasX, point.dy - biasY),
      Offset(point.dx - biasX, point.dy + biasY),
      Offset(point.dx + biasX, point.dy + biasY),
      Offset(point.dx + biasX, point.dy - biasY),
    ];
    
    if (coord is PolarCoordComponent) {
      abstractPoints = abstractPoints.map(
        (p) => Offset(
          _normalize(p.dx, biasX),
          _normalize(p.dy, biasY),
        )
      ).toList();
    }

    final points = abstractPoints.map(
      (p) => coord.convertPoint(p)
    );

    rst.add(PolygonRenderShape(
      points: points,
      color: color,
    ));
  }

  return rst;
}
