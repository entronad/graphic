import 'dart:ui';

import 'segment.dart';
import 'cubic.dart';

/// Converts a line to cubic bezier control points.
List<Offset> lineToCubicControls(Offset start, Offset end) =>
    [Offset.lerp(start, end, 0.5)!, end];

/// A line segment like [Path.lineTo].
class LineSegment extends Segment {
  /// Creates a line segment.
  LineSegment({
    required this.end,
    String? tag,
  }) : super(
          tag: tag,
        );

  /// The end point of this line.
  final Offset end;

  @override
  void drawPath(Path path) => path.lineTo(end.dx, end.dy);

  @override
  LineSegment lerpFrom(covariant LineSegment from, double t) => LineSegment(
        end: Offset.lerp(from.end, end, t)!,
        tag: tag,
      );

  @override
  CubicSegment toCubic(Offset start) {
    final controlsRst = lineToCubicControls(start, end);

    return CubicSegment(
      control1: controlsRst.first,
      control2: controlsRst.last,
      end: end,
      tag: tag,
    );
  }

  @override
  LineSegment sow(Offset position) => LineSegment(
        end: position,
        tag: tag,
      );

  @override
  Offset getEnd() => end;

  @override
  bool operator ==(Object other) =>
      other is LineSegment && super == other && end == other.end;
}
