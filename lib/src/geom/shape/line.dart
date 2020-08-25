import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/polyline.dart';
import 'package:graphic/src/engine/render_shape/polygon.dart';
import 'package:graphic/src/coord/polar.dart';

import '../base.dart';

List<RenderShape> _line(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
  bool smooth,
) {
  final firstRecord = attrValueRecords.first;
  final color = firstRecord.color;
  final size = firstRecord.size;

  final points = <Offset>[];

  if (coord is PolarCoordComponent) {

    // radar

    assert(
      !coord.state.transposed,
      'Do not transpose polar coord for line shapes',
    );
    assert(
      !smooth,
      'smooth line shapes only support cartesian coord',
    );

    for (var record in attrValueRecords) {
      final point = record.position.first;
      points.add(coord.convertPoint(point));
    }

    return [PolygonRenderShape(
      points: points,
      color: color,
      style: PaintingStyle.stroke,
      strokeWidth: size,
    )];
  } else {
    for (var record in attrValueRecords) {
      final point = record.position.first;
      points.add(coord.convertPoint(point));
    }

    return [PolylineRenderShape(
      points: points,
      color: color,
      strokeWidth: size,
      smooth: smooth,
    )];
  }
}

List<RenderShape> line(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _line(attrValueRecords, coord, false);

List<RenderShape> smoothLine(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _line(attrValueRecords, coord, true);
