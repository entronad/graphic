import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/util/math.dart';

import 'axis.dart';

class CircularAxisPainter extends AxisPainter<PolarCoordConv> {
  CircularAxisPainter(
    List<TickInfo> ticks,
    double position,
    bool flip,
    StrokeStyle? line,
    PolarCoordConv coord,
  ) : super(
    ticks,
    position,
    flip,
    line,
    coord,
  );

  @override
  void paint(Canvas canvas) {
    final flipSign = flip ? -1 : 1;
    final r = coord.radius * position;

    if (line != null) {
      canvas.drawArc(
        Rect.fromCircle(center: coord.center, radius: r),
        coord.startAngle,
        coord.endAngle - coord.startAngle,
        false,
        line!.toPaint()
          ..style = PaintingStyle.stroke,
      );
    }

    for (var tick in ticks) {
      // Polar coord dose not has tickLine.
      assert(tick.tickLine == null);

      final angle = coord.convertAngle(tick.position);
      if (angle >= coord.startAngle && angle <= coord.endAngle) {
        if (tick.label != null) {
          final labelAnchor = coord.polarToOffset(angle, r);
          Alignment align;
          // According to anchor's quadrant.
          final anchorOffset = labelAnchor - coord.center;
          align = Alignment(
            anchorOffset.dx.equalTo(0)
              ? 0
              : anchorOffset.dx / anchorOffset.dx.abs() * flipSign,
            anchorOffset.dy.equalTo(0)
              ? 0
              : anchorOffset.dy / anchorOffset.dy.abs() * flipSign,
          );
          paintLabel(
            Label(tick.text, tick.label!),
            labelAnchor,
            align,
            canvas,
          );
        }
      }
    }
  }
}

class CircularGridPainter extends GridPainter<PolarCoordConv> {
  CircularGridPainter(
    List<TickInfo> ticks,
    PolarCoordConv coord,
  ) : super(
    ticks,
    coord,
  );

  @override
  void paint(Canvas canvas) {
    final region = coord.region;
    for (var tick in ticks) {
      if (tick.grid != null) {
        final angle = coord.convertAngle(tick.position);
        if (angle >= coord.startAngle && angle <= coord.endAngle) {
          canvas.drawLine(
            coord.polarToOffset(angle, coord.innerRadius),
            coord.polarToOffset(angle, coord.radius),
            tick.grid!.toPaint(),
          );
        }
      }
    }
  }
}
