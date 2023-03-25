import 'dart:ui';

import 'package:flutter/painting.dart';

import 'element.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/line.dart';
import 'segment/arc_to_point.dart';
import 'segment/close.dart';

class RectElement extends PrimitiveElement {
  RectElement({
    required this.rect,
    this.borderRadius,
    required PaintStyle style,
    double? rotation,
    Offset? rotationAxis,
    String? tag,
  }) : super(
          style: style,
          rotation: rotation,
          rotationAxis: rotationAxis,
          tag: tag,
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
  RectElement lerpFrom(covariant RectElement from, double t) => RectElement(
        rect: Rect.lerp(from.rect, rect, t)!,
        borderRadius: BorderRadius.lerp(from.borderRadius, borderRadius, t),
        style: style.lerpFrom(from.style, t),
        rotation: lerpDouble(from.rotation, rotation, t),
        rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
        tag: tag,
      );

  @override
  List<Segment> toSegments() {
    if (borderRadius == null) {
      return [
        MoveSegment(end: rect.topLeft),
        LineSegment(end: rect.topRight, tag: SegmentTags.top),
        LineSegment(end: rect.bottomRight, tag: SegmentTags.right),
        LineSegment(end: rect.bottomLeft, tag: SegmentTags.bottom),
        LineSegment(end: rect.topLeft, tag: SegmentTags.left),
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
        ArcToPointSegment(
            end: rect.topLeft.translate(signX * tlr.x, 0),
            radius: tlr,
            rotation: 0,
            largeArc: false,
            clockwise: clockwise,
            tag: SegmentTags.topLeft),
        LineSegment(
            end: rect.topRight.translate(-signX * trr.x, 0),
            tag: SegmentTags.top),
        ArcToPointSegment(
            end: rect.topRight.translate(0, signY * trr.y),
            radius: trr,
            rotation: 0,
            largeArc: false,
            clockwise: clockwise,
            tag: SegmentTags.topRight),
        LineSegment(
            end: rect.bottomRight.translate(0, -signY * brr.y),
            tag: SegmentTags.right),
        ArcToPointSegment(
            end: rect.bottomRight.translate(-signX * brr.x, 0),
            radius: brr,
            rotation: 0,
            largeArc: false,
            clockwise: clockwise,
            tag: SegmentTags.bottomRight),
        LineSegment(
            end: rect.bottomLeft.translate(signX * blr.x, 0),
            tag: SegmentTags.bottom),
        ArcToPointSegment(
            end: rect.bottomLeft.translate(0, -signY * blr.y),
            radius: blr,
            rotation: 0,
            largeArc: false,
            clockwise: clockwise,
            tag: SegmentTags.bottomLeft),
        LineSegment(
            end: rect.topLeft.translate(0, signY * tlr.y),
            tag: SegmentTags.left),
        CloseSegment(),
      ];
    }
  }

  @override
  bool operator ==(Object other) =>
      other is RectElement &&
      super == other &&
      rect == other.rect &&
      borderRadius == other.borderRadius;
}
