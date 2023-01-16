import 'dart:ui';

import 'mark.dart';
import 'segment/segment.dart';

class PathMark extends ShapeMark {
  PathMark({
    required this.segments,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
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
}
