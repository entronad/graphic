import 'dart:ui';

import 'segment.dart';

class ArcSegment extends Segment {
  ArcSegment({
    required this.end,
    this.radius = Radius.zero,
    this.rotation = 0,
    this.largeArc = false,
    this.clockwise = true,

    bool relative = false,
  }) : super(
    relative: relative,
  );

  final Offset end;

  final Radius radius;

  final double rotation;

  final bool largeArc;

  final bool clockwise;
  
  @override
  void absoluteDrawPath(Path path) =>
    path.arcToPoint(end, radius: radius, rotation: rotation, largeArc: largeArc, clockwise: clockwise);
  
  @override
  void relativeDrawPath(Path path) =>
    path.relativeArcToPoint(end, radius: radius, rotation: rotation, largeArc: largeArc, clockwise: clockwise);
}
