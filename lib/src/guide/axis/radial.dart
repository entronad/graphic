import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/util/math.dart';

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
    final angle = coord.startAngle + position * coord.endAngle;

    if (line != null) {
      final lineStart = coord.polarToOffset(angle, coord.innerRadius);
      final lineEnd = coord.polarToOffset(angle, coord.radius);
      canvas.drawLine(
        lineStart,
        lineEnd,
        line!.toPaint(),
      );
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
    for (var tick in ticks) {
      if (tick.grid != null) {
        final r = coord.convertRadius(tick.position);
        if (r >= coord.innerRadius && r <= coord.radius) {
          canvas.drawArc(
            Rect.fromCircle(center: coord.center, radius: r),
            coord.startAngle,
            coord.endAngle - coord.startAngle,
            false,
            tick.grid!.toPaint()
              ..style = PaintingStyle.stroke,
          );
        }
      }
    }
  }
}
