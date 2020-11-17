import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/custom.dart';
import 'package:graphic/src/engine/util/smooth.dart' as smooth_util;
import 'package:graphic/src/util/math.dart';

import 'base.dart';
import '../base.dart';

abstract class AreaShape extends Shape {}

class BasicAreaShape extends AreaShape {
  BasicAreaShape({this.smooth = false});

  final bool smooth;

  @override
  List<RenderShape> getRenderShape(
    List<ElementRecord> records,
    CoordComponent coord,
    Offset origin,
  ) {
    assert(
      !(coord is PolarCoordComponent && coord.state.transposed),
      'Do not transpose polar coord for area shapes',
    );
    assert(
      !(coord is PolarCoordComponent && smooth),
      'smooth area shapes only support cartesian coord',
    );

    final firstRecord = records.first;
    final color = firstRecord.color;

    final segments = <List<List<Offset>>>[];

    // Disconnect invalid points
    var currentSegment = <List<Offset>>[];
    for (var record in records) {
      final startPoint = record.position.first;
      final endPoint = record.position.last;
      if (isValid(startPoint.dy) && isValid(endPoint.dy)) {
        currentSegment.add(record.position);
      } else if (currentSegment.isNotEmpty) {
        segments.add(currentSegment);
        currentSegment = <List<Offset>>[];
      }
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    // Rada
    if (
      coord is PolarCoordComponent
        && isValid(records.first.position.first.dy)
        && isValid(records.first.position.last.dy)
        && isValid(records.last.position.first.dy)
        && isValid(records.last.position.last.dy)
    ) {
      segments.last.add(segments.first.first);
    }

    final rst = <RenderShape>[];

    for (var segment in segments) {
      final topPoints = <Offset>[];
      final bottomPoints = <Offset>[];
      for (var position in segment) {
        topPoints.add(coord.convertPoint(position.last));
        bottomPoints.add(coord.convertPoint(position.first));
      }

      final path = Path();

      path.moveTo(topPoints.first.dx, topPoints.first.dy);
      if (smooth) {
        final segments = smooth_util.smooth(
          topPoints,
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
        for (var point in topPoints) {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.lineTo(bottomPoints.last.dx, bottomPoints.last.dy);
      final reversedBottomPoints = bottomPoints.reversed.toList();
      if (smooth) {
        final segments = smooth_util.smooth(
          reversedBottomPoints,
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
        for (var point in reversedBottomPoints) {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();

      rst.add(CustomRenderShape(
        path: path,
        color: color,
      ));
    }

    return rst;
  }
}
