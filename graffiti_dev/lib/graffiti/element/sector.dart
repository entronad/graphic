import 'dart:math';
import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:graffiti_dev/graffiti/element/segment/arc.dart';

import 'package:graphic/src/util/math.dart';

import 'element.dart';
import 'path.dart';
import 'segment/segment.dart';
import 'segment/close.dart';
import 'segment/line.dart';
import 'segment/move.dart';
import 'segment/quadratic.dart';

List<Segment> _getSectorSegments({
  required Offset center,
  required double startRadius,
  required double endRadius,
  required double startAngle,
  required double endAngle,
  BorderRadius? borderRadius,
}) {
  final sweepAngle = endAngle - startAngle;
  final radialInterval = endRadius - startRadius;
  
  if (sweepAngle.equalTo(0) || radialInterval.equalTo(0)) {
    return [];
  }

  final sweepAngleAbs = sweepAngle.abs();

  // The canvas can not fill a ring, so it is devided to two semi rings.
  if (sweepAngleAbs.equalTo(pi * 2)) {
    return [
      ..._getSectorSegments(center: center, startRadius: startRadius, endRadius: endRadius, startAngle: 0, endAngle: pi),
      ..._getSectorSegments(center: center, startRadius: startRadius, endRadius: endRadius, startAngle: pi, endAngle: pi * 2),
    ];
  }

  late final List<Segment> rst;
  if (borderRadius == null || borderRadius == BorderRadius.zero) {
    rst = [
      MoveSegment(end: Offset(cos(startAngle) * endRadius + center.dx, sin(startAngle) * endRadius + center.dy)),
      ArcSegment(oval: Rect.fromCircle(center: center, radius: endRadius), startAngle: startAngle, endAngle: endAngle, tag: SegmentTags.top),
      LineSegment(end: Offset(cos(endAngle) * startRadius + center.dx, sin(endAngle) * startRadius + center.dy), tag: SegmentTags.right),
      ArcSegment(oval: Rect.fromCircle(center: center, radius: startRadius), startAngle: endAngle, endAngle: startAngle, tag: SegmentTags.bottom),
      LineSegment(end: Offset(cos(startAngle) * endRadius + center.dx, sin(startAngle) * endRadius + center.dy), tag: SegmentTags.left),
      CloseSegment(),
    ];
  } else {
    double arcStart;
    double arcEnd;

    // Makes sure the corners correct when radiuses or angles are reversed.

    final cornerCircularSign = sweepAngle / sweepAngleAbs;
    final cornerRadialSign = radialInterval / radialInterval.abs();

    // Calculates the top angles.

    arcStart = startAngle + cornerCircularSign * (borderRadius.topLeft.x / endRadius);
    arcEnd = endAngle - cornerCircularSign * (borderRadius.topRight.x / endRadius);

    rst = <Segment>[];

    // The top left corner.

    rst.add(MoveSegment(end: Offset(
      cos(startAngle) * (endRadius - cornerRadialSign * borderRadius.topLeft.y) + center.dx,
      sin(startAngle) * (endRadius - cornerRadialSign * borderRadius.topLeft.y) + center.dy,
    )));
    rst.add(QuadraticSegment(control: Offset(cos(startAngle) * endRadius + center.dx, sin(startAngle) * endRadius + center.dy), end: Offset(cos(arcStart) * endRadius + center.dx, sin(arcStart) * endRadius + center.dy), tag: SegmentTags.topLeft));

    // The top arc.

    rst.add(ArcSegment(oval: Rect.fromCircle(center: center, radius: endRadius), startAngle: arcStart, endAngle: arcEnd, tag: SegmentTags.top));

    // The top right corner.

    rst.add(QuadraticSegment(control: Offset(cos(endAngle) * endRadius + center.dx, sin(endAngle) * endRadius + center.dy), end: Offset(cos(endAngle) * (endRadius - cornerRadialSign * borderRadius.topRight.y) + center.dx, sin(endAngle) * (endRadius - cornerRadialSign * borderRadius.topRight.y) + center.dy), tag: SegmentTags.topRight));
    rst.add(LineSegment(end: Offset(
      cos(endAngle) * (startRadius + cornerRadialSign * borderRadius.bottomRight.y) + center.dx,
      sin(endAngle) * (startRadius + cornerRadialSign * borderRadius.bottomRight.y) + center.dy,
    ), tag: SegmentTags.right));

    // Calculates the bottom angles.

    arcStart = startAngle + cornerCircularSign * (borderRadius.bottomLeft.x / startRadius);
    arcEnd = endAngle - cornerCircularSign * (borderRadius.bottomRight.x / startRadius);

    // The bottom right corner.

    rst.add(QuadraticSegment(control: Offset(cos(endAngle) * startRadius + center.dx, sin(endAngle) * startRadius + center.dy), end: Offset(cos(arcEnd) * startRadius + center.dx, sin(arcEnd) * startRadius + center.dy), tag: SegmentTags.bottomRight));

    // The bottom arc.

    rst.add(ArcSegment(oval: Rect.fromCircle(center: center, radius: startRadius), startAngle: arcEnd, endAngle: arcStart, tag: SegmentTags.bottom));

    // The bottom left corner.

    rst.add(QuadraticSegment(control: Offset(cos(startAngle) * startRadius + center.dx, sin(startAngle) * startRadius + center.dy), end: Offset(cos(startAngle) * (startRadius + cornerRadialSign * borderRadius.bottomLeft.y) + center.dx, sin(startAngle) * (startRadius + cornerRadialSign * borderRadius.bottomLeft.y) + center.dy), tag: SegmentTags.bottomLeft));

    rst.add(LineSegment(end: Offset(
      cos(startAngle) * (endRadius - cornerRadialSign * borderRadius.topLeft.y) + center.dx,
      sin(startAngle) * (endRadius - cornerRadialSign * borderRadius.topLeft.y) + center.dy,
    ), tag: SegmentTags.left));
    rst.add(CloseSegment());
  }
  return rst;
}

class SectorElement extends PathElement {
  SectorElement({
    required this.center,
    required this.startRadius,
    required this.endRadius,
    required this.startAngle,
    required this.endAngle,
    this.borderRadius,

    PaintStyle? style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    segments: _getSectorSegments(center: center, startRadius: startRadius, endRadius: endRadius, startAngle: startAngle, endAngle: endAngle, borderRadius: borderRadius),
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Offset center;

  final double startRadius;

  final double endRadius;

  final double startAngle;

  final double endAngle;

  final BorderRadius? borderRadius;

  @override
  SectorElement lerpFrom(covariant SectorElement from, double t) => SectorElement(
    center: Offset.lerp(from.center, center, t)!,
    startRadius: lerpDouble(from.startRadius, startRadius, t)!,
    endRadius: lerpDouble(from.endRadius, endRadius, t)!,
    startAngle: lerpDouble(from.startAngle, startAngle, t)!,
    endAngle: lerpDouble(from.endAngle, endAngle, t)!,
    borderRadius: BorderRadius.lerp(from.borderRadius, borderRadius, t),
    style: style.lerpFrom(from.style, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
  );
}
