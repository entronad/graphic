import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/math.dart';
import 'package:graphic/src/util/path.dart';

import 'axis.dart';

/// Always behind the axis in clockwise forword.
Alignment radialLabelAlign(Offset offset) {
  if (offset.dx.equalTo(0)) {
    if (offset.dy.equalTo(0)) {
      return Alignment.center;
    } else if (offset.dy > 0) {
      return Alignment.centerRight;
    } else {
      // offset.dy < 0
      return Alignment.centerLeft;
    }
  } else if (offset.dx > 0) {
    if (offset.dy.equalTo(0)) {
      return Alignment.topCenter;
    } else if (offset.dy > 0) {
      return Alignment.topRight;
    } else {
      // offset.dy < 0
      return Alignment.topLeft;
    }
  } else {
    // offset.dx < 0
    if (offset.dy.equalTo(0)) {
      return Alignment.bottomCenter;
    } else if (offset.dy > 0) {
      return Alignment.bottomRight;
    } else {
      // offset.dy < 0
      return Alignment.bottomLeft;
    }
  }
}

List<Figure>? renderRadialAxis(
  List<TickInfo> ticks,
  double position,
  bool flip,
  StrokeStyle? line,
  PolarCoordConv coord,
) {
  final rst = <Figure>[];

  final flipSign = flip ? -1.0 : 1.0;
  final angle =
      coord.startAngle + (coord.endAngle - coord.startAngle) * position;

  if (line != null) {
    rst.add(PathFigure(
      Paths.line(
        from: coord.polarToOffset(angle, coord.startRadius),
        to: coord.polarToOffset(angle, coord.endRadius),
      ),
      line.toPaint(),
    ));
  }

  for (var tick in ticks) {
    // Polar coord dose not has tickLine.
    assert(tick.tickLine == null);

    final r = coord.convertRadius(tick.position);
    if (r >= coord.startRadius && r <= coord.endRadius) {
      if (tick.label != null) {
        final labelAnchor = coord.polarToOffset(angle, r);
        final anchorOffset = labelAnchor - coord.center;
        rst.add(renderLabel(
          Label(tick.text, tick.label!),
          labelAnchor,
          radialLabelAlign(anchorOffset) * flipSign,
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}

List<Figure>? renderRadialGrid(
  List<TickInfo> ticks,
  PolarCoordConv coord,
) {
  final rst = <Figure>[];

  for (var tick in ticks) {
    if (tick.grid != null) {
      final r = coord.convertRadius(tick.position);
      if (r >= coord.startRadius && r <= coord.endRadius) {
        rst.add(PathFigure(
          Path()
            ..addArc(
              Rect.fromCircle(center: coord.center, radius: r),
              coord.startAngle,
              coord.endAngle - coord.startAngle,
            ),
          tick.grid!.toPaint()..style = PaintingStyle.stroke,
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}
