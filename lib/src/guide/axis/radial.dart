import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/math.dart';
import 'package:graphic/src/util/path.dart';

import 'axis.dart';

List<Figure>? drawRadialAxis(
  List<TickInfo> ticks,
  double position,
  bool flip,
  StrokeStyle? line,
  PolarCoordConv coord,
) {
  final rst = <Figure>[];

  final flipSign = flip ? -1 : 1;
  final angle = coord.startAngle + position * coord.endAngle;

  if (line != null) {
    rst.add(PathFigure(
      Paths.line(
        from: coord.polarToOffset(angle, coord.innerRadius),
        to: coord.polarToOffset(angle, coord.radius),
      ),
      line.toPaint(),
    ));
  }

  for (var tick in ticks) {
    // Polar coord dose not has tickLine.
    assert(tick.tickLine == null);

    final r = coord.convertRadius(tick.position);
    if (r >= coord.innerRadius && r <= coord.radius) {
      if (tick.label != null) {
        final labelAnchor = coord.polarToOffset(angle, r);
        Alignment align;
        // According to anchor's quadrant.
        final anchorOffset = labelAnchor - coord.center;
        align = Alignment(
          anchorOffset.dx.equalTo(0)
            ? 1
            : anchorOffset.dx / anchorOffset.dx.abs() * flipSign,
          anchorOffset.dy.equalTo(0)
            ? -1
            : anchorOffset.dy / anchorOffset.dy.abs() * flipSign,
        );
        rst.add(drawLabel(
          Label(tick.text, tick.label!),
          labelAnchor,
          align,
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}

List<Figure>? drawRadialGrid(
  List<TickInfo> ticks,
  PolarCoordConv coord,
) {
  final rst = <Figure>[];

  for (var tick in ticks) {
    if (tick.grid != null) {
      final r = coord.convertRadius(tick.position);
      if (r >= coord.innerRadius && r <= coord.radius) {
        rst.add(PathFigure(
          Path()..addArc(
            Rect.fromCircle(center: coord.center, radius: r),
            coord.startAngle,
            coord.endAngle - coord.startAngle,
          ),
          tick.grid!.toPaint()
            ..style = PaintingStyle.stroke,
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}
