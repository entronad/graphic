import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/math.dart';
import 'package:graphic/src/util/path.dart';

import 'axis.dart';

/// Renders circular axis.
List<Figure>? renderCircularAxis(
  List<TickInfo> ticks,
  double position,
  bool flip,
  StrokeStyle? line,
  PolarCoordConv coord,
) {
  final rst = <Figure>[];

  final flipSign = flip ? -1.0 : 1.0;
  final r =
      coord.startRadius + (coord.endRadius - coord.startRadius) * position;

  if (line != null) {
    rst.add(PathFigure(
      line.dashPath(Path()
        ..addArc(
          Rect.fromCircle(center: coord.center, radius: r),
          coord.startAngle,
          coord.endAngle - coord.startAngle,
        )),
      line.toPaint()..style = PaintingStyle.stroke,
    ));
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
        rst.add(renderLabel(
          Label(tick.text, tick.label!),
          labelAnchor,
          defaultAlign,
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}

/// Renders circular axis grid.
List<Figure>? renderCircularGrid(
  List<TickInfo> ticks,
  PolarCoordConv coord,
) {
  final rst = <Figure>[];

  for (var tick in ticks) {
    if (tick.grid != null) {
      final angle = coord.convertAngle(tick.position);
      if (angle >= coord.startAngle && angle <= coord.endAngle) {
        rst.add(PathFigure(
          tick.grid!.dashPath(Paths.line(
            from: coord.polarToOffset(angle, coord.startRadius),
            to: coord.polarToOffset(angle, coord.endRadius),
          )),
          tick.grid!.toPaint(),
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}
