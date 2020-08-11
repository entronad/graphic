import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/cartesian.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/custom.dart';
import 'package:graphic/src/engine/render_shape/polygon.dart';
import 'package:graphic/src/engine/util/smooth.dart' as smooth_util;

import '../base.dart';

List<RenderShape> _area(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
  bool smooth,
) {
  final firstRecord = attrValueRecords.first;
  final color = firstRecord.color;
  final multiPosition = firstRecord.position.length == 2;

  if (multiPosition) {

    // With top and bottom two edges.

    assert(
      coord is CartesianCoordComponent,
      'Multi position area shapes only support cartesian coord',
    );

    final topPoints = <Offset>[];
    final bottomPoints = <Offset>[];
    for (var i = 0; i < attrValueRecords.length; i++) {
      final topPoint = attrValueRecords[i].position.first;
      final bottomPoint = attrValueRecords[i].position.last;
      topPoints.add(coord.convertPoint(topPoint));
      bottomPoints.add(coord.convertPoint(bottomPoint));
    }

    final path = Path();
    path.moveTo(topPoints.first.dx, topPoints.first.dy);
    if (smooth) {
      final segments = smooth_util.smooth(
        topPoints,
        false,
        coord.state.region,
      );
      for (var s in segments) {
        path.cubicTo(
          s.cp1.dx,
          s.cp1.dy,
          s.cp2.dx,
          s.cp2.dy,
          s.p.dx,
          s.p.dy
        );
      }
    } else {
      for (var point in topPoints) {
        path.lineTo(point.dx, point.dy);
      }
    }
    final reversedBottomPoints = bottomPoints.reversed;
    path.lineTo(
      reversedBottomPoints.first.dx,
      reversedBottomPoints.first.dy,
    );
    if (smooth) {
      final segments = smooth_util.smooth(
        reversedBottomPoints,
        false,
        coord.state.region,
      );
      for (var s in segments) {
        path.cubicTo(
          s.cp1.dx,
          s.cp1.dy,
          s.cp2.dx,
          s.cp2.dy,
          s.p.dx,
          s.p.dy
        );
      }
    } else {
      for (var point in reversedBottomPoints) {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    return [CustomRenderShape(
      path: path,
      color: color,
    )];
  } else {

    // Only with top edge.

    final points = <Offset>[];
    for (var i = 0; i < attrValueRecords.length; i++) {
      final point = attrValueRecords[i].position.first;
      points.add(coord.convertPoint(point));
    }

    if (coord is PolarCoordComponent) {
      assert(
        !smooth,
        'smooth area shapes only support cartesian coord',
      );

      return [PolygonRenderShape(
        points: points,
        color: color,
      )];
    } else {
      final path = Path();
      final bottomLeft = Offset(points.first.dx, 0);
      final bottomRight = Offset(points.last.dx, 0);

      path.moveTo(bottomLeft.dx, bottomLeft.dy);
      path.lineTo(points.first.dx, points.first.dy);

      if (smooth) {
        final segments = smooth_util.smooth(
          points,
          false,
          coord.state.region,
        );
        for (var s in segments) {
          path.cubicTo(
            s.cp1.dx,
            s.cp1.dy,
            s.cp2.dx,
            s.cp2.dy,
            s.p.dx,
            s.p.dy
          );
        }
      } else {
        for (var point in points) {
          path.lineTo(point.dx, point.dy);
        }
      }

      path.lineTo(bottomRight.dx, bottomRight.dy);
      path.close();

      return [CustomRenderShape(
        path: path,
        color: color,
      )];
    }
  }
  
}

List<RenderShape> area(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _area(attrValueRecords, coord, false);

List<RenderShape> smoothArea(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _area(attrValueRecords, coord, true);
