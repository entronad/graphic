import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/rect.dart';

import 'axis.dart';

class HorizontalAxisPainter extends AxisPainter<RectCoordConv> {
  HorizontalAxisPainter(
    List<TickInfo> ticks,
    double position,
    bool flip,
    StrokeStyle? line,
    RectCoordConv coord,
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
    final y = region.bottom - position * region.height;

    if (line != null) {
      canvas.drawLine(
        Offset(region.left, y),
        Offset(region.right, y),
        line!.toPaint(),
      );
    }

    for (var tick in ticks) {
      final coordLeft = coord.horizontals.first;
      final coordRight = coord.horizontals.last;
      final x = coordLeft + tick.position * (coordRight - coordLeft);
      if (x >= region.left && x <= region.right) {
        if (tick.tickLine != null) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x, y + tick.tickLine!.length * flipSign),
            line!.toPaint(),
          );
        }
        if (tick.label != null) {
          paintLabel(
            Label(tick.text, tick.label!),
            Offset(
              x,
              y + tick.tickLine!.length * flipSign,
            ),
            flip ? Alignment.topCenter : Alignment.bottomCenter,
            canvas,
          );
        }
      }
    }
  }
}

class HorizontalGridPainter extends GridPainter<RectCoordConv> {
  HorizontalGridPainter(
    List<TickInfo> ticks,
    RectCoordConv coord,
  ) : super(
    ticks,
    coord,
  );

  @override
  void paint(Canvas canvas) {
    final region = coord.region;
    for (var tick in ticks) {
      if (tick.grid != null) {
        final coordLeft = coord.horizontals.first;
        final coordRight = coord.horizontals.last;
        final x = coordLeft + tick.position * (coordRight - coordLeft);
        if (x >= region.left && x <= region.right) {
          canvas.drawLine(
            Offset(x, region.bottom),
            Offset(x, region.top),
            tick.grid!.toPaint(),
          );
        }
      }
    }
  }
}
