import 'dart:ui';
import 'dart:math';

import 'element.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/cubic.dart';
import 'segment/close.dart';

/// A circle element.
class CircleElement extends PrimitiveElement {
  /// Creates a circle element.
  CircleElement({
    required this.center,
    required this.radius,
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

  /// The center point of this circle.
  final Offset center;

  /// The radius of this circle.
  final double radius;

  @override
  void drawPath(Path path) =>
      path.addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  CircleElement lerpFrom(covariant CircleElement from, double t) =>
      CircleElement(
        center: Offset.lerp(from.center, center, t)!,
        radius: lerpDouble(from.radius, radius, t)!,
        style: style.lerpFrom(from.style, t),
        rotation: lerpDouble(from.rotation, rotation, t),
        rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
        tag: tag,
      );

  @override
  List<Segment> toSegments() {
    const factor = ((-1 + sqrt2) / 3) * 4;
    final d = radius * factor;

    return [
      MoveSegment(end: center.translate(-radius, 0)),
      CubicSegment(
          control1: center.translate(-radius, -d),
          control2: center.translate(-d, -radius),
          end: center.translate(0, -radius),
          tag: SegmentTags.top),
      CubicSegment(
          control1: center.translate(d, -radius),
          control2: center.translate(radius, -d),
          end: center.translate(radius, 0),
          tag: SegmentTags.right),
      CubicSegment(
          control1: center.translate(radius, d),
          control2: center.translate(d, radius),
          end: center.translate(0, radius),
          tag: SegmentTags.bottom),
      CubicSegment(
          control1: center.translate(-d, radius),
          control2: center.translate(-radius, d),
          end: center.translate(-radius, 0),
          tag: SegmentTags.left),
      CloseSegment(),
    ];
  }

  @override
  bool operator ==(Object other) =>
      other is CircleElement &&
      super == other &&
      center == other.center &&
      radius == other.radius;
}
