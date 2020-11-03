import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/polyline.dart';
import 'package:graphic/src/engine/render_shape/polygon.dart';
import 'package:graphic/src/coord/polar.dart';

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
    final firstRecord = records.first;
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

      for (var record in records) {
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
      for (var record in records) {
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
}
