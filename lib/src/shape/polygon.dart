import 'dart:ui';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/shape/util/aes_basic_item.dart';

import 'partition.dart';
import 'util/paths.dart';

abstract class PolygonShape extends PartitionShape {}

class HeatmapShape extends PolygonShape {
  HeatmapShape({
    this.topLeft = Radius.zero,
    this.topRight = Radius.zero,
    this.bottomRight = Radius.zero,
    this.bottomLeft = Radius.zero,
    this.sector = false,
  }) : rrect = 
    topLeft != Radius.zero ||
    topRight != Radius.zero ||
    bottomRight != Radius.zero ||
    bottomLeft != Radius.zero;

  final bool rrect;

  /// Top start angle for polar.
  /// X is circular and y is radial.
  final Radius topLeft;

  /// Top end angle for polar.
  /// X is circular and y is radial.
  final Radius topRight;

  /// Bottom end angle for polar.
  /// X is circular and y is radial.
  final Radius bottomRight;

  /// Bottom start angle for polar.
  /// X is circular and y is radial.
  final Radius bottomLeft;

  /// Wheather the polygon is sector in polar coord.
  final bool sector;

  @override
  bool equalTo(Object other) =>
    other is HeatmapShape &&
    topLeft == other.topLeft &&
    topRight == other.topRight &&
    bottomRight == other.bottomRight &&
    bottomLeft == other.bottomLeft &&
    sector == other.sector;

  @override
  void paintGroup(
    List<Aes> group,
    CoordConv coord,
    Canvas canvas,
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

    for (var item in group) {
      assert(item is HeatmapShape);

      final point = item.position.last;
      final path = Path();
      if (coord is RectCoordConv) {
        assert(!sector);

        final rect = Rect.fromPoints(
          coord.convert(Offset(point.dx - biasX, point.dy + biasY)), // topLeft
          coord.convert(Offset(point.dx + biasX, point.dy - biasY)), // bottomRight
        );
        if (rrect) {
          path.addRRect(RRect.fromRectAndCorners(
            rect,
            topLeft: topLeft,
            topRight: topRight,
            bottomRight: bottomRight,
            bottomLeft: bottomLeft,
          ));
        } else {
          path.addRect(rect);
        }
      } else {
        assert(!rrect);

        if (sector) {
          coord as PolarCoordConv;
          final startAngle = coord.transposed ? point.dy - biasY : point.dx - biasX;
          final endAngle = coord.transposed? point.dy + biasY : point.dx + biasX;
          final r = coord.transposed ? point.dx + biasX : point.dy + biasY;
          final r0 = coord.transposed ? point.dx - biasX : point.dy - biasY;
          Paths.sector(
            center: coord.center,
            r: coord.convertRadius(r),
            r0: coord.convertRadius(r0),
            startAngle: coord.convertAngle(startAngle),
            endAngle: coord.convertAngle(endAngle),
            clockwise: true,
            path: path,
          );
        } else {
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

      aesBasicItem(
        path,
        item,
        false,
        0,
        canvas,
      );
      if (item.label != null) {
        paintLabel(
          item.label!,
          coord.convert(point),
          Alignment.center,
          canvas,
        );
      }
    }
  }
}
