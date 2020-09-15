import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/custom.dart';
import 'package:graphic/src/engine/render_shape/polygon.dart';
import 'package:graphic/src/engine/util/smooth.dart' as smooth_util;

import '../base.dart';

List<RenderShape> _area(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
  Offset origin,
  bool smooth,
) {
  final firstRecord = attrValueRecords.first;
  final color = firstRecord.color;

  final points = <Offset>[];
  
  if (coord is PolarCoordComponent) {
    
    // radar

    assert(
      !coord.state.transposed,
      'Do not transpose polar coord for area shapes',
    );
    assert(
      !smooth,
      'smooth area shapes only support cartesian coord',
    );

    for (var record in attrValueRecords) {
      final point = record.position.first;
      points.add(coord.convertPoint(point));
    }

    return [PolygonRenderShape(
      points: points,
      color: color,
    )];
  } else {
    final path = Path();

    for (var record in attrValueRecords) {
      final point = record.position.first;
      points.add(coord.convertPoint(point));
    }

    // render points
    Offset bottomStart;
    Offset bottomEnd;
    final renderOrigin = coord.convertPoint(origin);
    if (coord.state.transposed) {
      final areaBottom = renderOrigin.dx;
      bottomStart = Offset(areaBottom, points.first.dy);
      bottomEnd = Offset(areaBottom, points.last.dy);
    } else {
      final areaBottom = renderOrigin.dy;
      bottomStart = Offset(points.first.dx, areaBottom);
      bottomEnd = Offset(points.last.dx, areaBottom);
    }

    path.moveTo(bottomStart.dx, bottomStart.dy);
    path.lineTo(points.first.dx, points.first.dy);
    if (smooth) {
      final segments = smooth_util.smooth(
        points,
        false,
        true,
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
    path.lineTo(bottomEnd.dx, bottomEnd.dy);
    path.close();

    return [CustomRenderShape(
      path: path,
      color: color,
    )];
  }
}

List<RenderShape> area(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
  Offset origin,
) => _area(attrValueRecords, coord, origin, false);

List<RenderShape> smoothArea(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
  Offset origin,
) => _area(attrValueRecords, coord, origin, true);
