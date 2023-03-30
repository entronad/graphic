import 'dart:ui';

import 'package:graphic/src/util/collection.dart';

import 'element.dart';
import 'segment/segment.dart';
import 'segment/move.dart';

/// An element specified by path [Segment]s.
class PathElement extends PrimitiveElement {
  /// Creates a path element.
  PathElement({
    required this.segments,
    required PaintStyle style,
    double? rotation,
    Offset? rotationAxis,
    String? tag,
  })  : assert(segments.first is MoveSegment),
        super(
          style: style,
          rotation: rotation,
          rotationAxis: rotationAxis,
          tag: tag,
        );

  /// The path segments of this element.
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
        tag: tag,
      );

  @override
  bool operator ==(Object other) =>
      other is PathElement &&
      super == other &&
      deepCollectionEquals(segments, other.segments);
}
