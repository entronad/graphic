import 'package:flutter/painting.dart';
import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/graffiti/element/arc.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/graffiti/element/label.dart';
import 'package:graphic/src/graffiti/element/line.dart';
import 'package:graphic/src/util/math.dart';

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
List<MarkElement>? renderRadialAxis(
  List<TickInfo> ticks,
  double position,
  bool flip,
  PaintStyle? line,
  PolarCoordConv coord,
) {
  final rst = <MarkElement>[];

  final flipSign = flip ? -1.0 : 1.0;
  final angle =
      coord.startAngle + (coord.endAngle - coord.startAngle) * position;

  if (line != null) {
    rst.add(LineElement(
        start: coord.polarToOffset(angle, coord.startRadius),
        end: coord.polarToOffset(angle, coord.endRadius),
        style: line));
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
    rst.add(LabelElement(
        text: tick.text!,
        anchor: labelAnchors[index]!,
        defaultAlign: labelAlign,
        style: tick.label!));
  }

  return rst.isEmpty ? null : rst;
}

/// Renders radial axis grid.
List<MarkElement>? renderRadialGrid(
  List<TickInfo> ticks,
  PolarCoordConv coord,
) {
  final rst = <MarkElement>[];

  for (var tick in ticks) {
    if (tick.grid != null) {
      final r = coord.convertRadius(tick.position);
      if (r >= coord.startRadius && r <= coord.endRadius) {
        rst.add(ArcElement(
            oval: Rect.fromCircle(center: coord.center, radius: r),
            startAngle: coord.startAngle,
            endAngle: coord.endAngle,
            style: tick.grid!));
      }
    }
  }

  return rst.isEmpty ? null : rst;
}
