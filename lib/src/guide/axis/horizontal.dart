import 'package:flutter/painting.dart';
import 'package:graphic/src/coord/rect.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/graffiti/element/line.dart';

import 'axis.dart';

/// Renders horizontal axis.
List<MarkElement>? renderHorizontalAxis(
  List<TickInfo> ticks,
  double position,
  bool flip,
  PaintStyle? line,
  RectCoordConv coord,
) {
  final rst = <MarkElement>[];

  final region = coord.region;
  final flipSign = flip ? -1.0 : 1.0;
  final y = region.bottom - region.height * position;

  if (line != null) {
    rst.add(LineElement(start: Offset(region.left, y), end: Offset(region.right, y), style: line));
  }

  for (var tick in ticks) {
    final coordLeft = coord.horizontals.first;
    final coordRight = coord.horizontals.last;
    final x = coordLeft + tick.position * (coordRight - coordLeft);
    if (x >= region.left && x <= region.right) {
      if (tick.tickLine != null) {
        rst.add(LineElement(start: Offset(x, y), end: Offset(x, y + tick.tickLine!.length * flipSign), style: tick.tickLine!.style));
      }
      if (tick.haveLabel) {
        rst.add(LabelElement(text: tick.text!, anchor: Offset(x, y), defaultAlign: flip ? Alignment.topCenter : Alignment.bottomCenter, style: tick.label));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}

/// Renders horizontal axis grid.
List<MarkElement>? renderHorizontalGrid(
  List<TickInfo> ticks,
  RectCoordConv coord,
) {
  final rst = <MarkElement>[];

  final region = coord.region;
  for (var tick in ticks) {
    if (tick.grid != null) {
      final coordLeft = coord.horizontals.first;
      final coordRight = coord.horizontals.last;
      final x = coordLeft + tick.position * (coordRight - coordLeft);
      if (x >= region.left && x <= region.right) {
        rst.add(LineElement(start: Offset(x, region.bottom), end: Offset(x, region.top), style: tick.grid));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}
