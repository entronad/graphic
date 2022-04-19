import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/polygon.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/path.dart';

import 'util/render_basic_item.dart';
import 'partition.dart';

/// The shape for the polygon element.
///
/// See also:
///
/// - [PolygonElement], which this shape is for.
abstract class PolygonShape extends PartitionShape {}

/// A heatmap shape.
class HeatmapShape extends PolygonShape {
  /// Creates a heatmap.
  HeatmapShape({
    this.sector = false,
    this.borderRadius,
  });

  /// The border radius of the rectangle or sector.
  ///
  /// For a sector, [Radius.x] is circular, [Radius.y] is radial, top is outer side,
  /// bottom is inner side, left is anticlockwise, right is clockwise.
  ///
  /// This will not work for polygon tiles in a polar coordinate.
  final BorderRadius? borderRadius;

  /// Wheather the tiles are sectors or polygons in a polar coordinate.
  final bool sector;

  @override
  bool equalTo(Object other) =>
      other is HeatmapShape &&
      sector == other.sector &&
      borderRadius == other.borderRadius;

  @override
  List<Figure> renderGroup(
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
          coord.convert(Offset(point.dx - biasX, point.dy + biasY)),
          coord.convert(Offset(point.dx + biasX, point.dy - biasY)),
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
          final startAngle =
              coord.transposed ? point.dy - biasY : point.dx - biasX;
          final endAngle =
              coord.transposed ? point.dy + biasY : point.dx + biasX;
          final r = coord.transposed ? point.dx + biasX : point.dy + biasY;
          final r0 = coord.transposed ? point.dx - biasX : point.dy - biasY;
          if (borderRadius != null) {
            Paths.rSector(
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

          // [topLeft, topRight, bottomRight, bottomLeft]
          final vertices = [
            Offset(point.dx - biasX, point.dy + biasY),
            Offset(point.dx + biasX, point.dy + biasY),
            Offset(point.dx + biasX, point.dy - biasY),
            Offset(point.dx - biasX, point.dy - biasY),
          ];
          path.addPolygon(
            vertices.map(coord.convert).toList(),
            true,
          );
        }
      }

      rst.addAll(renderBasicItem(
        path,
        item,
        false,
        0,
        coord.region,
      ));

      if (item.label != null && item.label!.haveText) {
        rst.add(renderLabel(
          item.label!,
          coord.convert(point),
          Alignment.center,
        ));
      }
    }

    return rst;
  }
}
