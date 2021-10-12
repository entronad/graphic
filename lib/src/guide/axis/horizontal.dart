import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/path.dart';

import 'axis.dart';

List<Figure>? drawHorizontalAxis(
  List<TickInfo> ticks,
  double position,
  bool flip,
  StrokeStyle? line,
  RectCoordConv coord,
) {
  final rst = <Figure>[];

  final region = coord.region;
  final flipSign = flip ? -1.0 : 1.0;
  final y = region.bottom - region.height * position;

  if (line != null) {
    rst.add(PathFigure(
      Paths.line(
        from: Offset(region.left, y),
        to: Offset(region.right, y),
      ),
      line.toPaint(),
    ));
  }

  for (var tick in ticks) {
    final coordLeft = coord.horizontals.first;
    final coordRight = coord.horizontals.last;
    final x = coordLeft + tick.position * (coordRight - coordLeft);
    if (x >= region.left && x <= region.right) {
      if (tick.tickLine != null) {
        rst.add(PathFigure(
          Paths.line(
            from: Offset(x, y),
            to: Offset(x, y + tick.tickLine!.length * flipSign),
          ),
          tick.tickLine!.style.toPaint(),
        ));
      }
      if (tick.label != null) {
        rst.add(drawLabel(
          Label(tick.text, tick.label!),
          Offset(x, y),
          flip ? Alignment.topCenter : Alignment.bottomCenter,
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}

List<Figure>? drawHorizontalGrid(
  List<TickInfo> ticks,
  RectCoordConv coord,
) {
  final rst = <Figure>[];

  final region = coord.region;
  for (var tick in ticks) {
    if (tick.grid != null) {
      final coordLeft = coord.horizontals.first;
      final coordRight = coord.horizontals.last;
      final x = coordLeft + tick.position * (coordRight - coordLeft);
      if (x >= region.left && x <= region.right) {
        rst.add(PathFigure(
          Paths.line(
            from: Offset(x, region.bottom),
            to: Offset(x, region.top),
          ),
          tick.grid!.toPaint(),
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}
