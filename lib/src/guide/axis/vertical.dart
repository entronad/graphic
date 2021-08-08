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
            Offset(
              x - tick.tickLine!.length * flipSign,
              y,
            ),
            flip ? Alignment.centerLeft : Alignment.centerRight,
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
