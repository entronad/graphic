import 'dart:ui';

import 'element.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/line.dart';

class LineElement extends PrimitiveElement {
  LineElement({
    required this.start,
    required this.end,
    PaintStyle? style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
          style: style ?? defaultPaintStyle,
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
  LineElement lerpFrom(covariant LineElement from, double t) => LineElement(
        start: Offset.lerp(from.start, start, t)!,
        end: Offset.lerp(from.end, end, t)!,
        style: style.lerpFrom(from.style, t),
        rotation: lerpDouble(from.rotation, rotation, t),
        rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
      );

  @override
  List<Segment> toSegments() => [
        MoveSegment(end: start),
        LineSegment(end: end, tag: SegmentTags.top),
      ];
}
