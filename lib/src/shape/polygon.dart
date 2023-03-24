import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/graffiti/element/polygon.dart';
import 'package:graphic/src/graffiti/element/rect.dart';
import 'package:graphic/src/graffiti/element/sector.dart';
import 'package:graphic/src/mark/polygon.dart';
import 'package:graphic/src/graffiti/element/element.dart';

import 'util/render_basic_item.dart';
import 'partition.dart';

/// The shape for the polygon mark.
///
/// See also:
///
/// - [PolygonMark], which this shape is for.
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
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
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

    final rst = <MarkElement>[];

    for (var item in group) {
      assert(item.shape is HeatmapShape);

      final style = getPaintStyle(item, false, 0, coord.region);

      final point = item.position.last;
      if (coord is RectCoordConv) {
        assert(!sector);
        rst.add(RectElement(
            rect: Rect.fromPoints(
              coord.convert(Offset(point.dx - biasX, point.dy + biasY)),
              coord.convert(Offset(point.dx + biasX, point.dy - biasY)),
            ),
            borderRadius: borderRadius,
            style: style));
      } else {
        if (sector) {
          coord as PolarCoordConv;
          final startAngle =
              coord.transposed ? point.dy - biasY : point.dx - biasX;
          final endAngle =
              coord.transposed ? point.dy + biasY : point.dx + biasX;
          final r = coord.transposed ? point.dx + biasX : point.dy + biasY;
          final r0 = coord.transposed ? point.dx - biasX : point.dy - biasY;
          rst.add(SectorElement(
            center: coord.center,
            endRadius: coord.convertRadius(r),
            startRadius: coord.convertRadius(r0),
            startAngle: coord.convertAngle(startAngle),
            endAngle: coord.convertAngle(endAngle),
            borderRadius: borderRadius,
            style: style,
          ));
        } else {
          assert(borderRadius == null);

          // [topLeft, topRight, bottomRight, bottomLeft]
          final vertices = [
            Offset(point.dx - biasX, point.dy + biasY),
            Offset(point.dx + biasX, point.dy + biasY),
            Offset(point.dx + biasX, point.dy - biasY),
            Offset(point.dx - biasX, point.dy - biasY),
          ];
          rst.add(PolygonElement(
              points: vertices.map(coord.convert).toList(), style: style));
        }
      }
    }
    return rst;
  }

  @override
  List<MarkElement> drawGroupLabels(
      List<Attributes> group, CoordConv coord, Offset origin) {
    final rst = <MarkElement>[];

    for (var item in group) {
      if (item.label != null && item.label!.haveText) {
        final point = item.position.last;
        rst.add(LabelElement(
            text: item.label!.text!,
            anchor: coord.convert(point),
            defaultAlign: Alignment.center,
            style: item.label!.style));
      }
    }

    return rst;
  }
}
