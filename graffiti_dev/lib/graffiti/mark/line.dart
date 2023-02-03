import 'dart:ui';

import 'mark.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/line.dart';

class LineMark extends ShapeMark {
  LineMark({
    required this.start,
    required this.end,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Offset start;

  final Offset end;
  
  @override
  void drawPath(Path path) {
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);
  }

  @override
  LineMark lerpFrom(covariant LineMark from, double t) => LineMark(
    start: Offset.lerp(from.start, start, t)!,
    end: Offset.lerp(from.end, end, t)!,
    style: style.lerpFrom(from.style, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
  );

  @override
  List<Segment> toSegments() => [
    MoveSegment(end: start),
    LineSegment(end: end),
  ];
}
