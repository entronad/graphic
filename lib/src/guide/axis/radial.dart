import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/polar.dart';

import 'axis.dart';

class RadialAxisPainter extends AxisPainter<PolarCoordConv> {
  RadialAxisPainter(
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
    final region = coord.region;
    final flipSign = flip ? -1 : 1;
    final angle = canvasAngleStart + position * canvasAngleEnd;

    if (line != null) {
      final lineEnd = coord.polarToOffset(angle, region.shortestSide);
      canvas.drawLine(
        region.center,
        lineEnd,
        line!.toPaint(),
      );
    }

    for (var tick in ticks) {
      // Polar coord dose not has tickLine.
      assert(tick.tickLine == null);

      final r = coord.convertRadius(tick.position);
      if (r >= 0 && r <= region.shortestSide) {
        if (tick.label != null) {
          final labelAnchor = coord.polarToOffset(angle, r);
          Alignment align;
          // According to anchor's quadrant.
          final anchorOffset = labelAnchor - coord.center;
          align = Alignment(
            anchorOffset.dx == 0 ? 1 : -anchorOffset.dx / anchorOffset.dx.abs() * flipSign,
            anchorOffset.dy == 0 ? 1 : -anchorOffset.dy / anchorOffset.dy.abs() * flipSign,
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

class RadialGridPainter extends GridPainter<PolarCoordConv> {
  RadialGridPainter(
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
        final r = coord.convertRadius(tick.position);
        if (r >= 0 && r <= region.shortestSide) {
          canvas.drawCircle(
            region.center,
            r,
            tick.grid!.toPaint(),
          );
        }
      }
    }
  }
}
