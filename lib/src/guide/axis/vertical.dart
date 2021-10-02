import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/rect.dart';

import 'axis.dart';

class VerticalAxisPainter extends AxisPainter<RectCoordConv> {
  VerticalAxisPainter(
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
    final x = region.left + position * region.width;
    
    if (line != null) {
      canvas.drawLine(
        Offset(x, region.bottom),
        Offset(x, region.top),
        line!.toPaint(),
      );
    }

    for (var tick in ticks) {
      final coordBottom = coord.verticals.first;
      final coordTop = coord.verticals.last;
      final y = coordBottom - tick.position * (coordBottom - coordTop);
      if (y >= region.top && y <= region.bottom) {
        if (tick.tickLine != null) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x - tick.tickLine!.length * flipSign, y),
            line!.toPaint(),
          );
        }
        if (tick.label != null) {
          paintLabel(
            Label(tick.text, tick.label!),
            Offset(x, y),
            flip ? Alignment.centerRight : Alignment.centerLeft,
            canvas,
          );
        }
      }
    }
  }
}

class VerticalGridPainter extends GridPainter<RectCoordConv> {
  VerticalGridPainter(
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
        final coordBottom = coord.verticals.first;
        final coordTop = coord.verticals.last;
        final y = coordBottom - tick.position * (coordBottom - coordTop);
        if (y >= region.top && y <= region.bottom) {
          canvas.drawLine(
            Offset(region.left, y),
            Offset(region.right, y),
            tick.grid!.toPaint(),
          );
        }
      }
    }
  }
}
