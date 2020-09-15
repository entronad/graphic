import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/polygon.dart';

import '../base.dart';

List<RenderShape> mosaicPolygon(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
  Offset origin,
) {
  var stepX = double.infinity;
  var stepY = double.infinity;
  for (var i = 0; i < attrValueRecords.length - 1; i++) {
    final point = attrValueRecords[i].position.first;
    final nextPoint = attrValueRecords[i + 1].position.first;
    final dx = (nextPoint.dx - point.dx).abs();
    final dy = (nextPoint.dy - point.dy).abs();
    if (dx != 0) {
      stepX = min(stepX, dx);
    }
    if (dy != 0) {
      stepY = min(stepY, dy);
    }
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
        (p) => p.translate(biasX, 0)
      ).toList();
    }

    final points = abstractPoints.map(
      (p) => coord.convertPoint(p)
    ).toList();

    rst.add(PolygonRenderShape(
      points: points,
      color: color,
    ));
  }

  return rst;
}
