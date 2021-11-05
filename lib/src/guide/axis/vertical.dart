import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/path.dart';

import 'axis.dart';

/// Renders vertical axis.
List<Figure>? renderVerticalAxis(
  List<TickInfo> ticks,
  double position,
  bool flip,
  StrokeStyle? line,
  RectCoordConv coord,
) {
  final rst = <Figure>[];

  final region = coord.region;
  final flipSign = flip ? -1.0 : 1.0;
  final x = region.left + region.width * position;

  if (line != null) {
    rst.add(PathFigure(
      Paths.line(
        from: Offset(x, region.bottom),
        to: Offset(x, region.top),
      ),
      line.toPaint(),
    ));
  }

  for (var tick in ticks) {
    final coordBottom = coord.verticals.first;
    final coordTop = coord.verticals.last;
    final y = coordBottom - tick.position * (coordBottom - coordTop);
    if (y >= region.top && y <= region.bottom) {
      if (tick.tickLine != null) {
        rst.add(PathFigure(
          Paths.line(
            from: Offset(x, y),
            to: Offset(x - tick.tickLine!.length * flipSign, y),
          ),
          tick.tickLine!.style.toPaint(),
        ));
      }
      if (tick.label != null) {
        rst.add(renderLabel(
          Label(tick.text, tick.label!),
          Offset(x, y),
          flip ? Alignment.centerRight : Alignment.centerLeft,
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}

/// Renders vertical axis grid.
List<Figure>? renderVerticalGrid(
  List<TickInfo> ticks,
  RectCoordConv coord,
) {
  final rst = <Figure>[];

  final region = coord.region;
  for (var tick in ticks) {
    if (tick.grid != null) {
      final coordBottom = coord.verticals.first;
      final coordTop = coord.verticals.last;
      final y = coordBottom - tick.position * (coordBottom - coordTop);
      if (y >= region.top && y <= region.bottom) {
        rst.add(PathFigure(
          Paths.line(
            from: Offset(region.left, y),
            to: Offset(region.right, y),
          ),
          tick.grid!.toPaint(),
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}
