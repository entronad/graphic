import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/util/math.dart';
import 'package:graphic/src/util/path.dart';

import 'axis.dart';

/// Calculates default radial axis lablel alignment.
///
/// They are always behind the axis in clockwise forword.
Alignment radialLabelAlign(Offset offset) {
  if (offset.dx.equalTo(0)) {
    if (offset.dy.equalTo(0)) {
      return Alignment.center;
    } else if (offset.dy > 0) {
      return Alignment.centerRight;
    } else {
      // offset.dy < 0
      return Alignment.centerLeft;
    }
  } else if (offset.dx > 0) {
    if (offset.dy.equalTo(0)) {
      return Alignment.topCenter;
    } else if (offset.dy > 0) {
      return Alignment.topRight;
    } else {
      // offset.dy < 0
      return Alignment.topLeft;
    }
  } else {
    // offset.dx < 0
    if (offset.dy.equalTo(0)) {
      return Alignment.bottomCenter;
    } else if (offset.dy > 0) {
      return Alignment.bottomRight;
    } else {
      // offset.dy < 0
      return Alignment.bottomLeft;
    }
  }
}

/// Renders radial axis.
List<Figure>? renderRadialAxis(
  List<TickInfo> ticks,
  double position,
  bool flip,
  StrokeStyle? line,
  PolarCoordConv coord,
) {
  final rst = <Figure>[];

  final flipSign = flip ? -1.0 : 1.0;
  final angle =
      coord.startAngle + (coord.endAngle - coord.startAngle) * position;

  if (line != null) {
    rst.add(PathFigure(
      line.dashPath(Paths.line(
        from: coord.polarToOffset(angle, coord.startRadius),
        to: coord.polarToOffset(angle, coord.endRadius),
      )),
      line.toPaint(),
    ));
  }

  // The align of all labels should be consist, so loop twice.

  final labelAnchors = <int, Offset>{};
  var featureOffset = Offset.zero;

  for (var i = 0; i < ticks.length; i++) {
    final tick = ticks[i];

    // Polar coord dose not allow tick lines.
    assert(tick.tickLine == null);

    final r = coord.convertRadius(tick.position);
    if (r >= coord.startRadius && r <= coord.endRadius) {
      if (tick.haveLabel) {
        final labelAnchor = coord.polarToOffset(angle, r);
        final anchorOffset = labelAnchor - coord.center;
        labelAnchors[i] = labelAnchor;
        if (anchorOffset != Offset.zero) {
          featureOffset = anchorOffset;
        }
      }
    }
  }

  final labelAlign = radialLabelAlign(featureOffset) * flipSign;
  for (var index in labelAnchors.keys) {
    final tick = ticks[index];
    rst.add(renderLabel(
      Label(tick.text, tick.label!),
      labelAnchors[index]!,
      labelAlign,
    ));
  }

  return rst.isEmpty ? null : rst;
}

/// Renders radial axis grid.
List<Figure>? renderRadialGrid(
  List<TickInfo> ticks,
  PolarCoordConv coord,
) {
  final rst = <Figure>[];

  for (var tick in ticks) {
    if (tick.grid != null) {
      final r = coord.convertRadius(tick.position);
      if (r >= coord.startRadius && r <= coord.endRadius) {
        rst.add(PathFigure(
          tick.grid!.dashPath(Path()
            ..addArc(
              Rect.fromCircle(center: coord.center, radius: r),
              coord.startAngle,
              coord.endAngle - coord.startAngle,
            )),
          tick.grid!.toPaint()..style = PaintingStyle.stroke,
        ));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}
