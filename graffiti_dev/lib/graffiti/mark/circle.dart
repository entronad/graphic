import 'dart:ui';
import 'dart:math';

import 'mark.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/cubic.dart';
import 'segment/close.dart';

class CircleMark extends ShapeMark {
  CircleMark({
    required this.center,
    required this.radius,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Offset center;

  final double radius;
  
  @override
  void drawPath(Path path) =>
    path.addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  CircleMark lerpFrom(covariant CircleMark from, double t) => CircleMark(
    center: Offset.lerp(from.center, center, t)!,
    radius: lerpDouble(from.radius, radius, t)!,
    style: style.lerpFrom(from.style, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
  );

  @override
  List<Segment> toSegments() {
    const factor = ((-1 + sqrt2) / 3) * 4;
    final d = radius * factor;

    return [
      MoveSegment(end: center.translate(-radius, 0)),
      CubicSegment(control1: center.translate(-radius, -d), control2: center.translate(-d, -radius), end: center.translate(0, -radius)),
      CubicSegment(control1: center.translate(d, -radius), control2: center.translate(radius, -d), end: center.translate(radius, 0)),
      CubicSegment(control1: center.translate(radius, d), control2: center.translate(d, radius), end: center.translate(0, radius)),
      CubicSegment(control1: center.translate(-d, radius), control2: center.translate(-radius, d), end: center.translate(-radius, 0)),
      CloseSegment(),
    ];
  }
}
