import 'dart:ui';

import 'element.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/line.dart';

class LineElement extends PrimitiveElement {
  LineElement({
    required this.start,
    required this.end,
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
        tag: tag,
      );

  @override
  List<Segment> toSegments() => [
        MoveSegment(end: start),
        LineSegment(end: end, tag: SegmentTags.top),
      ];

  @override
  bool operator ==(Object other) =>
      other is LineElement &&
      super == other &&
      start == other.start &&
      end == other.end;
}
