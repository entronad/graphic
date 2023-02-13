import 'dart:ui';
import 'dart:math';

import 'mark.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/cubic.dart';
import 'segment/close.dart';

class OvalMark extends ShapeMark {
  OvalMark({
    required this.oval,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Rect oval;
  
  @override
  void drawPath(Path path) =>
    path.addOval(oval);

  @override
  OvalMark lerpFrom(covariant OvalMark from, double t) => OvalMark(
    oval: Rect.lerp(from.oval, oval, t)!,
    style: style.lerpFrom(from.style, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
  );

  @override
  List<Segment> toSegments() {
    final rx = oval.width / 2;
    final ry = oval.height / 2;
    final cx = oval.center.dx;
    final cy = oval.center.dy;
    const factor = ((-1 + sqrt2) / 3) * 4;
    final dx = rx * factor;
    final dy = ry * factor;
    
    return [
      MoveSegment(end: oval.centerLeft),
      CubicSegment(control1: Offset(oval.left, cy - dy), control2: Offset(cx - dx, oval.top), end: oval.topCenter, tag: SegmentTags.top),
      CubicSegment(control1: Offset(cx + dx, oval.top), control2: Offset(oval.right, cy - dy), end: oval.centerRight, tag: SegmentTags.right),
      CubicSegment(control1: Offset(oval.right, cy + dy), control2: Offset(cx + dx, oval.bottom), end: oval.bottomCenter, tag: SegmentTags.bottom),
      CubicSegment(control1: Offset(cx - dx, oval.bottom), control2: Offset(oval.left, cy + dy), end: oval.centerLeft, tag: SegmentTags.left),
      CloseSegment(),
    ];
  }
}
