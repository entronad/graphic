import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/polyline.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/util/math.dart';

import 'base.dart';
import '../base.dart';

abstract class LineShape extends Shape {}

class BasicLineShape extends LineShape {
  BasicLineShape({this.smooth = false});

  final bool smooth;

  @override
  List<RenderShape> getRenderShape(
    List<ElementRecord> records,
    CoordComponent coord,
    Offset origin,
  ) {
    assert(
      !(coord is PolarCoordComponent && coord.state.transposed),
      'Do not transpose polar coord for line shapes',
    );
    assert(
      !(coord is PolarCoordComponent && smooth),
      'smooth line shapes only support cartesian coord',
    );

    final firstRecord = records.first;
    final color = firstRecord.color;
    final size = firstRecord.size;

    final segments = <List<Offset>>[];

    // Disconnect invalid points
    var currentSegment = <Offset>[];
    for (var record in records) {
      final point = record.position.first;
      if (isValid(point.dy)) {
        currentSegment.add(point);
      } else if (currentSegment.isNotEmpty) {
        segments.add(currentSegment);
        currentSegment = <Offset>[];
      }
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    // Rada
    if (
      coord is PolarCoordComponent
        && isValid(records.first.position.first.dy)
        && isValid(records.last.position.first.dy)
    ) {
      segments.last.add(segments.first.first);
    }

    final rst = <RenderShape>[];

    for (var segment in segments) {
      final points = segment.map(coord.convertPoint).toList();

      rst.add(PolylineRenderShape(
        points: points,
        color: color,
        strokeWidth: size,
        smooth: smooth,
      ));
    }

    return rst;
  }
}
