import 'dart:ui';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/path.dart';

import 'util/aes_basic_item.dart';
import 'partition.dart';

abstract class PolygonShape extends PartitionShape {}

class HeatmapShape extends PolygonShape {
  HeatmapShape({
    this.sector = false,
    this.borderRadius,
  });

  /// X is circular and y is radial.
  final BorderRadius? borderRadius;

  /// Wheather the polygon is sector in polar coord.
  final bool sector;

  @override
  bool equalTo(Object other) =>
    other is HeatmapShape &&
    sector == other.sector &&
    borderRadius == other.borderRadius;

  @override
  List<Figure> drawGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
  ) {
    var stepX = double.infinity;
    var stepY = double.infinity;
    for (var i = 0; i < group.length - 1; i++) {
      final point = group[i].position.last;
      final nextPoint = group[i + 1].position.last;
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

    final rst = <Figure>[];

    for (var item in group) {
      assert(item.shape is HeatmapShape);

      final point = item.position.last;
      final path = Path();
      if (coord is RectCoordConv) {
        assert(!sector);

        final rect = Rect.fromPoints(
          coord.convert(Offset(point.dx - biasX, point.dy + biasY)), // topLeft
          coord.convert(Offset(point.dx + biasX, point.dy - biasY)), // bottomRight
        );
        if (borderRadius != null) {
          path.addRRect(RRect.fromRectAndCorners(
            rect,
            topLeft: borderRadius!.topLeft,
            topRight: borderRadius!.topRight,
            bottomRight: borderRadius!.bottomRight,
            bottomLeft: borderRadius!.bottomLeft,
          ));
        } else {
          path.addRect(rect);
        }
      } else {
        if (sector) {
          coord as PolarCoordConv;
          final startAngle = coord.transposed ? point.dy - biasY : point.dx - biasX;
          final endAngle = coord.transposed? point.dy + biasY : point.dx + biasX;
          final r = coord.transposed ? point.dx + biasX : point.dy + biasY;
          final r0 = coord.transposed ? point.dx - biasX : point.dy - biasY;
          if (borderRadius != null) {
            Paths.rsector(
              center: coord.center,
              r: coord.convertRadius(r),
              r0: coord.convertRadius(r0),
              startAngle: coord.convertAngle(startAngle),
              endAngle: coord.convertAngle(endAngle),
              clockwise: true,
              path: path,
              topLeft: borderRadius!.topLeft,
              topRight: borderRadius!.topRight,
              bottomRight: borderRadius!.bottomRight,
              bottomLeft: borderRadius!.bottomLeft,
            );
          } else {
            Paths.sector(
              center: coord.center,
              r: coord.convertRadius(r),
              r0: coord.convertRadius(r0),
              startAngle: coord.convertAngle(startAngle),
              endAngle: coord.convertAngle(endAngle),
              clockwise: true,
              path: path,
            );
          }
        } else {
          assert(borderRadius == null);

          final vertices = [
            Offset(point.dx - biasX, point.dy + biasY),  // topLeft
            Offset(point.dx + biasX, point.dy + biasY),  // topRight
            Offset(point.dx + biasX, point.dy - biasY),  // bottomRight
            Offset(point.dx - biasX, point.dy - biasY),  // bottomLeft
          ];
          path.addPolygon(
            vertices.map(coord.convert).toList(),
            true,
          );
        }
      }

      rst.addAll(drawBasicItem(
        path,
        item,
        false,
        0,
      ));

      if (item.label != null) {
        rst.add(drawLabel(
          item.label!,
          coord.convert(point),
          Alignment.center,
        ));
      }
    }

    return rst;
  }
}
