import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/custom.dart';
import 'package:graphic/src/engine/util/smooth.dart' as smooth_util;

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

    final topPoints = <Offset>[];
    final bottomPoints = <Offset>[];
    for (var record in records) {
      topPoints.add(coord.convertPoint(record.position.last));
      bottomPoints.add(coord.convertPoint(record.position.first));
    }

    // radar
    if (coord is PolarCoordComponent) {
      topPoints.add(topPoints.first);
      bottomPoints.add(bottomPoints.first);
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

    return [CustomRenderShape(
      path: path,
      color: color,
    )];
  }
}
