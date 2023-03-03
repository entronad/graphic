import 'dart:ui';

import 'element.dart';
import 'segment/segment.dart';
import 'segment/move.dart';

class PathElement extends ShapeElement {
  PathElement({
    required this.segments,

    ShapeStyle? style,
    double? rotation,
    Offset? rotationAxis,
  }) : assert(segments.first is MoveSegment),
  super(
    style: style ?? defaultShapeStyle,
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
  PathElement lerpFrom(covariant PathElement from, double t) => PathElement(
    segments: lerpSegments(from.segments, segments, t),
    style: style.lerpFrom(from.style, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
  );
}
