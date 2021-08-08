import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/polar.dart';

import 'axis.dart';

class CircularAxisPainter extends AxisPainter<PolarCoordConv> {
  CircularAxisPainter(
    List<TickInfo> ticks,
    double position,
    bool flip,
    StrokeStyle? line,
    PolarCoordConv coord,
    Rect region,
  ) : super(
    ticks,
    position,
    flip,
    line,
    coord,
    region,
  );

  @override
  void paint(Canvas canvas) {
    final flipSign = flip ? -1 : 1;
    final r = region.shortestSide * position;

    if (line != null) {
      canvas.drawCircle(
        region.center,
        region.shortestSide * position,
        line!.toPaint(),
      );
    }

    for (var tick in ticks) {
      // Polar coord dose not has tickLine.
      assert(tick.tickLine == null);

      final angle = coord.convertAngle(tick.position);
      if (angle >= canvasAngleStart && angle <= canvasAngleEnd) {
        if (tick.label != null) {
          final labelAnchor = coord.polarToOffset(angle, r);
          Alignment align;
          // According to anchor's quadrant.
          final anchorOffset = labelAnchor - coord.center;
          align = Alignment(
            anchorOffset.dx == 0 ? 0 : -anchorOffset.dx / anchorOffset.dx.abs() * flipSign,
            anchorOffset.dy == 0 ? 0 : -anchorOffset.dy / anchorOffset.dy.abs() * flipSign,
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
    Rect region,
  ) : super(
    ticks,
    coord,
    region,
  );

  @override
  void paint(Canvas canvas) {
    for (var tick in ticks) {
      if (tick.grid != null) {
        final angle = coord.convertAngle(tick.position);
        if (angle >= canvasAngleStart && angle <= canvasAngleEnd) {
          canvas.drawLine(
            region.center,
            coord.polarToOffset(angle, region.shortestSide),
            tick.grid!.toPaint(),
          );
        }
      }
    }
  }
}
