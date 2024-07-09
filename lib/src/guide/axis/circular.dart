import 'package:flutter/painting.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/graffiti/element/arc.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/graffiti/element/line.dart';
import 'package:graphic/src/graffiti/element/rect.dart';
import 'package:graphic/src/util/math.dart';

import 'axis.dart';

/// Renders circular axis.
List<MarkElement>? renderCircularAxis(
  List<TickInfo> ticks,
  double position,
  bool flip,
  PaintStyle? line,
  PolarCoordConv coord,
) {
  final rst = <MarkElement>[];

  final flipSign = flip ? -1.0 : 1.0;
  final r =
      coord.startRadius + (coord.endRadius - coord.startRadius) * position;

  if (line != null) {
    rst.add(ArcElement(
        oval: Rect.fromCircle(center: coord.center, radius: r),
        startAngle: coord.startAngle,
        endAngle: coord.endAngle,
        style: line));
  }

  for (var tick in ticks) {
    // Polar coord dose not allow tick lines.
    assert(tick.tickLine == null);

    final angle = coord.convertAngle(tick.position);
    if (angle >= coord.startAngle && angle <= coord.endAngle) {
      if (tick.haveLabel) {
        final labelAnchor = coord.polarToOffset(angle, r);
        Alignment defaultAlign;
        // Calculate default alignment according to anchor's quadrant.
        final anchorOffset = labelAnchor - coord.center;
        defaultAlign = Alignment(
              anchorOffset.dx.equalTo(0)
                  ? 0
                  : anchorOffset.dx / anchorOffset.dx.abs(),
              anchorOffset.dy.equalTo(0)
                  ? 0
                  : anchorOffset.dy / anchorOffset.dy.abs(),
            ) *
            flipSign;

        final label = LabelElement(
            text: tick.text!,
            anchor: labelAnchor,
            defaultAlign: defaultAlign,
            style: tick.label!);

        if (tick.haveLabelBackground) {
          rst.add(RectElement(
            rect: label.getBlock(),
            style: tick.labelBackground!,
          ));
        }

        rst.add(label);
      }
    }
  }

  return rst.isEmpty ? null : rst;
}

/// Renders circular axis grid.
List<MarkElement>? renderCircularGrid(
  List<TickInfo> ticks,
  PolarCoordConv coord,
) {
  final rst = <MarkElement>[];

  for (var tick in ticks) {
    if (tick.grid != null) {
      final angle = coord.convertAngle(tick.position);
      if (angle >= coord.startAngle && angle <= coord.endAngle) {
        rst.add(LineElement(
            start: coord.polarToOffset(angle, coord.startRadius),
            end: coord.polarToOffset(angle, coord.endRadius),
            style: tick.grid!));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}
