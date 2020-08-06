import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/polyline.dart';

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
  for (var i = 0; i < attrValueRecords.length; i++) {
    final point = attrValueRecords[i].position.first;
    final renderPosition = coord.convertPoint(Offset(
      point.dx,
      point.dy,
    ));
    points.add(renderPosition);
  }

  return [PolylineRenderShape(
    points: points,
    color: color,
    strokeWidth: size,
    smooth: smooth,
  )];
}

List<RenderShape> line(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _line(attrValueRecords, coord, false);

List<RenderShape> smoothLine(
  List<AttrValueRecord> attrValueRecords,
  CoordComponent coord,
) => _line(attrValueRecords, coord, true);
