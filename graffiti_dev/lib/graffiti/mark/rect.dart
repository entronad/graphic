import 'dart:ui';

import 'package:flutter/painting.dart';

import 'mark.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/line.dart';
import 'segment/arc_to_point.dart';
import 'segment/close.dart';

class RectMark extends ShapeMark {
  RectMark({
    required this.rect,
    this.borderRadius,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Rect rect;

  final BorderRadius? borderRadius;
  
  @override
  void drawPath(Path path) {
    if (borderRadius == null || borderRadius == BorderRadius.zero) {
      path.addRect(rect);
    } else {
      path.addRRect(borderRadius!.toRRect(rect));
    }
  }

  @override
  RectMark lerpFrom(covariant RectMark from, double t) => RectMark(
    rect: Rect.lerp(from.rect, rect, t)!,
    borderRadius: BorderRadius.lerp(from.borderRadius, borderRadius, t),
    style: style.lerpFrom(from.style, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
  );

  @override
  List<Segment> toSegments() {
    if (borderRadius == null) {
      return [
        MoveSegment(end: rect.topLeft),
        LineSegment(end: rect.topRight),
        LineSegment(end: rect.bottomRight),
        LineSegment(end: rect.bottomLeft),
        CloseSegment(),
      ];
    } else {
      final tlr = borderRadius!.topLeft;
      final trr = borderRadius!.topRight;
      final brr = borderRadius!.bottomRight;
      final blr = borderRadius!.bottomLeft;
      final signX = rect.width > 0 ? 1 : -1;
      final signY = rect.height > 0 ? 1 : -1;
      final clockwise = signX + signY != 0;

      return [
        MoveSegment(end: rect.topLeft.translate(0, signY * tlr.y)),
        ArcToPointSegment(end: rect.topLeft.translate(signX * tlr.x, 0), radius: tlr, clockwise: clockwise),
        LineSegment(end: rect.topRight.translate(-signX * trr.x, 0)),
        ArcToPointSegment(end: rect.topRight.translate(0, signY * trr.y), radius: trr, clockwise: clockwise),
        LineSegment(end: rect.bottomRight.translate(0, -signY * brr.y)),
        ArcToPointSegment(end: rect.bottomRight.translate(-signX * brr.x, 0), radius: brr, clockwise: clockwise),
        LineSegment(end: rect.bottomLeft.translate(signX * blr.x, 0)),
        ArcToPointSegment(end: rect.bottomLeft.translate(0, -signY * blr.y), radius: blr, clockwise: clockwise),
        CloseSegment(),
      ];
    }
  }
}
