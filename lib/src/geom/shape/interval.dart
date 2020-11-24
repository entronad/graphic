import 'dart:ui';

import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/coord/cartesian.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/rect.dart';
import 'package:graphic/src/engine/render_shape/sector.dart';
import 'package:graphic/src/engine/render_shape/polygon.dart';
import 'package:graphic/src/util/list.dart';
import 'package:graphic/src/util/math.dart';

import '../base.dart';
import 'base.dart';

abstract class IntervalShape extends Shape {}

// position: [start, end]

double _getPolarRadius(double value, double start, double end) =>
  (end - start) * value + start;

List<RenderShape> _slopedIntervals(
  List<ElementRecord> records,
  CoordComponent coord,
  bool sharp,
  Offset origin,
) {
  assert(
    coord is CartesianCoordComponent,
    'Pyramid and funnel shapes only support cartesian coord',
  );
  assert(
    records.length >= 2,
    'Pyramid and funnel shapes data length must >= 2',
  );

  final scaledXs = records.map((record) => record.position.first.dx).toList();
  var expandedXs = <double>[];
  expandedXs.add(scaledXs[0] - (scaledXs[1] - scaledXs[0]) / 2);
  for (var i = 0; i < scaledXs.length - 1; i++) {
    expandedXs.add((scaledXs[i] + scaledXs[i + 1]) / 2);
  }
  final last = scaledXs[scaledXs.length - 1];
  final secondaryLast = scaledXs[scaledXs.length - 2];
  expandedXs.add(last + (last - secondaryLast) / 2);

  final expandedstartYs = records.map((record) => record.position.first.dy).toList();
  final expandedendYs = records.map((record) => record.position.last.dy).toList();
  if (sharp) {
    expandedstartYs.add(origin.dy);
    expandedendYs.add(origin.dy);
  } else {
    expandedstartYs.add(expandedstartYs.last);
    expandedendYs.add(expandedendYs.last);
  }

  final rst = <RenderShape>[];
  
  for (var i = 0; i < expandedXs.length - 1; i++) {
    final points = [
      coord.convertPoint(Offset(
        expandedXs[i],
        expandedstartYs[i],
      )),
      coord.convertPoint(Offset(
        expandedXs[i],
        expandedendYs[i],
      )),
      coord.convertPoint(Offset(
        expandedXs[i + 1],
        expandedendYs[i + 1],
      )),
      coord.convertPoint(Offset(
        expandedXs[i + 1],
        expandedstartYs[i + 1],
      )),
    ];
    final color = records[i].color;

    rst.add(PolygonRenderShape(
      points: points,
      color: color,
    ));
  }

  return rst;
}

class RectShape extends IntervalShape {
  RectShape({this.radius = Radius.zero});

  final Radius radius;
  
  @override
  List<RenderShape> getRenderShape(
    List<ElementRecord> records,
    CoordComponent coord,
    Offset origin,
  ) {
    final rst = <RenderShape>[];

    if (coord is PolarCoordComponent) {
      final center = coord.center;
      final radiusLength = coord.radiusLength;
      final startAngle = coord.state.startAngle;
      final totalAngle = coord.state.endAngle - coord.state.startAngle;
      final count = records.length;
      
      if (coord.state.transposed) {

        // Pie

        final rangeYs = records.map(
          (record) {
            final startY = record.position.first.dy;
            final endY = record.position.last.dy;
            // check valid
            return (isValid(startY) && isValid(endY))
              ? record.position.last.dy - record.position.first.dy
              : 0;
          },
        ).toList();
        final totalScaledY = rangeYs.reduce((a, b) => a + b);
        var preAngle = startAngle;
        for (var i = 0; i < count; i++) {
          final record = records[i];
          final color = record.color;
          final swipeAngle = (rangeYs[i] / totalScaledY) * totalAngle;

          rst.add(SectorRenderShape(
            x: center.dx,
            y: center.dy,
            r: radiusLength * coord.state.radius,
            r0: radiusLength * coord.state.innerRadius,
            startAngle: preAngle,
            endAngle: preAngle + swipeAngle,
            color: color,
          ));

          preAngle = preAngle + swipeAngle;
        }
      } else {

        // Rose

        for (var i = 0; i < count; i++) {
          final record = records[i];
          final startY = record.position.first.dy;
          final endY = record.position.last.dy;

          if (!isValid(startY) || !isValid(endY)) {
            rst.add(null);
            continue;
          }

          final startX = record.position.first.dx;
          final endX = get(records, i + 1)?.position?.first?.dx ?? 1.0;
          final color = record.color;

          final r0 = _getPolarRadius(
            startY,
            coord.state.innerRadius,
            coord.state.radius,
          ) * radiusLength;
          final r = _getPolarRadius(
            endY,
            coord.state.innerRadius,
            coord.state.radius,
          ) * radiusLength;
          
          rst.add(SectorRenderShape(
            x: center.dx,
            y: center.dy,
            r: r,
            r0: r0,
            startAngle: startAngle + startX * totalAngle,
            endAngle: startAngle + endX * totalAngle,
            color: color,
          ));
        }
      }
    } else {

      // Bar

      final sizeStepRatio = 0.5;
      var size = records.first.size;
      if (size == null) {
        size = records.first.position.first.dx * 2 * sizeStepRatio * coord.state.region.width;
      }

      for (var i = 0; i < records.length; i++) {
        final record = records[i];
        final startY = record.position.first.dy;
        final endY = record.position.last.dy;

        if (!isValid(startY) || !isValid(endY)) {
          rst.add(null);
          continue;
        }
        
        final startPoint = coord.convertPoint(record.position.first);
        final endPoint = coord.convertPoint(record.position.last);
        final color = record.color;

        double x;
        double y;
        double width;
        double height;
        if (coord.state.transposed) {
          x = startPoint.dx;
          y = startPoint.dy - size / 2;
          width = endPoint.dx - startPoint.dx;
          height = size;
        } else {
          x = endPoint.dx - size / 2;
          y = endPoint.dy;
          width = size;
          height = startPoint.dy - endPoint.dy;
        }
        
        rst.add(RectRenderShape(
          x: x,
          y: y,
          width: width,
          height: height,
          color: color,
          radius: radius,
        ));
      }
    }

    return rst;
  }
}

class PyramidShape extends IntervalShape {
  @override
  List<RenderShape> getRenderShape(
    List<ElementRecord> records,
    CoordComponent coord,
    Offset origin,
  ) => _slopedIntervals(records, coord, true, origin);
}

class FunnelShape extends IntervalShape {
  @override
  List<RenderShape> getRenderShape(
    List<ElementRecord> records,
    CoordComponent coord,
    Offset origin,
  ) => _slopedIntervals(records, coord, false, origin);
}
