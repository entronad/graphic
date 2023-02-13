import 'dart:ui';

import 'mark.dart';
import 'segment/segment.dart';
import 'segment/move.dart';

class PathMark extends ShapeMark {
  PathMark({
    required this.segments,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : assert(segments.first is MoveSegment),
  super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final List<Segment> segments;
  
  @override
  void drawPath(Path path) {
    for (var segment in segments) {
      segment.drawPath(path);
    }
  }

  @override
  List<Segment> toSegments() => segments;
  
  @override
  PathMark lerpFrom(covariant PathMark from, double t) => PathMark(
    segments: lerpSegments(from.segments, segments, t),
    style: style.lerpFrom(from.style, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
  );
}
