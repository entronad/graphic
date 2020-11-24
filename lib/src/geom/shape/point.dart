import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/polygon.dart';
import 'package:graphic/src/engine/render_shape/circle.dart';
import 'package:graphic/src/engine/render_shape/rect.dart';
import 'package:graphic/src/util/math.dart';

import 'base.dart';
import '../base.dart';

abstract class PointShape extends Shape {}

class CircleShape extends PointShape {
  CircleShape({
    this.hollow = false,
    this.strokeWidth = 1,
  });

  final bool hollow;
  final double strokeWidth;

  @override
  List<RenderShape> getRenderShape(
    List<ElementRecord> records,
    CoordComponent coord,
    Offset origin,
  ) {
    final rst = <RenderShape>[];

    for (var record in records) {
      var point = record.position.first;

      if (!isValid(point.dy)) {
        rst.add(null);
        continue;
      }

      final size = record.size;
      final color = record.color;
      
      final paintingStyle = hollow ? PaintingStyle.stroke : PaintingStyle.fill;
      final r = hollow ? size - strokeWidth / 2 : size;
      final renderPosition = coord.convertPoint(point);
      final x = renderPosition.dx;
      final y = renderPosition.dy;

      rst.add(CircleRenderShape(
        x: x,
        y: y,
        r: r,
        color: color,
        style: paintingStyle,
        strokeWidth: strokeWidth,
      ));
    }

    return rst;
  }
}

class SquareShape extends PointShape {
  SquareShape({
    this.hollow = false,
    this.strokeWidth = 1
  });

  final bool hollow;
  final double strokeWidth;

  @override
  List<RenderShape> getRenderShape(
    List<ElementRecord> records,
    CoordComponent coord,
    Offset origin,
  ) {
    final rst = <RenderShape>[];

  for (var record in records) {
    var point = record.position.first;

    if (!isValid(point.dy)) {
      rst.add(null);
      continue;
    }

    final size = record.size;
    final color = record.color;
    
    final paintingStyle = hollow ? PaintingStyle.stroke : PaintingStyle.fill;
    var width = size * 2;
    final renderPosition = coord.convertPoint(point);
    var x = renderPosition.dx - size;
    var y = renderPosition.dy - size;
    if (hollow) {
      width = width - strokeWidth;
      x = x + strokeWidth / 2;
      y = y + strokeWidth / 2;
    }
    final height = width;
    
    rst.add(RectRenderShape(
      x: x,
      y: y,
      width: width,
      height: height,
      color: color,
      style: paintingStyle,
      strokeWidth: strokeWidth,
    ));
  }

  return rst;
  }
}

class TileShape extends PointShape {
  @override
  List<RenderShape> getRenderShape(
    List<ElementRecord> records,
    CoordComponent coord,
    Offset origin,
  ) {
    // For tile shape, both x and y must be valid.
    var stepX = double.infinity;
    var stepY = double.infinity;
    for (var i = 0; i < records.length - 1; i++) {
      final point = records[i].position.first;
      final nextPoint = records[i + 1].position.first;
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

    for (var record in records) {
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
}
