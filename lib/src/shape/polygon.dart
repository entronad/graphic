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
import 'package:graphic/src/util/collection.dart';

import 'util/style.dart';
import 'partition.dart';

/// The shape for the polygon mark.
///
/// See also:
///
/// - [PolygonMark], which this shape is for.
abstract class PolygonShape extends PartitionShape {}

/// A heatmap shape.
///
/// The rule of generating the tile size is: 1. all tiles have the same size. 2.
/// tries to inflate all the coordinate space. If there may be too few data items
/// (like only one in a dimension) to infer the size, [tileCounts] should be set.
class HeatmapShape extends PolygonShape {
  /// Creates a heatmap.
  HeatmapShape({
    this.sector = false,
    this.borderRadius,
    this.tileCounts,
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

  /// Total tile counts of each dimension.
  ///
  /// If any one is null, the time size of that dimension will be infered from data.
  final List<int?>? tileCounts;

  @override
  bool equalTo(Object other) =>
      other is HeatmapShape &&
      sector == other.sector &&
      borderRadius == other.borderRadius &&
      deepCollectionEquals(tileCounts, other.tileCounts);

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    double? stepXRst = tileCounts?[0] == null ? null : 1 / tileCounts![0]!;
    double? stepYRst = tileCounts?[1] == null ? null : 1 / tileCounts![1]!;

    if (stepXRst == null || stepYRst == null) {
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
      if (!stepX.isFinite) {
        stepX = 1;
      }
      if (!stepY.isFinite) {
        stepY = 1;
      }

      stepXRst = stepXRst ?? stepX;
      stepYRst = stepYRst ?? stepY;
    }

    final biasX = stepXRst / 2;
    final biasY = stepYRst / 2;

    final rst = <MarkElement>[];

    for (var item in group) {
      assert(item.shape is HeatmapShape);

      final style = getPaintStyle(item, false, 0, null, null);

      final point = item.position.last;
      if (coord is RectCoordConv) {
        assert(!sector);
        rst.add(RectElement(
          rect: Rect.fromPoints(
            coord.convert(Offset(point.dx - biasX, point.dy + biasY)),
            coord.convert(Offset(point.dx + biasX, point.dy - biasY)),
          ),
          borderRadius: (item.shape as HeatmapShape).borderRadius,
          style: style,
          tag: item.tag,
        ));
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
            borderRadius: (item.shape as HeatmapShape).borderRadius,
            style: style,
            tag: item.tag,
          ));
        } else {
          assert((item.shape as HeatmapShape).borderRadius == null);

          // [topLeft, topRight, bottomRight, bottomLeft]
          final vertices = [
            Offset(point.dx - biasX, point.dy + biasY),
            Offset(point.dx + biasX, point.dy + biasY),
            Offset(point.dx + biasX, point.dy - biasY),
            Offset(point.dx - biasX, point.dy - biasY),
          ];
          rst.add(PolygonElement(
              points: vertices.map(coord.convert).toList(),
              style: style,
              tag: item.tag));
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
          style: item.label!.style,
          tag: item.tag,
        ));
      }
    }

    return rst;
  }
}
