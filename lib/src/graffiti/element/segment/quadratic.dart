import 'dart:ui';

import 'segment.dart';
import 'cubic.dart';

/// Converts a quadratic bezier segment to cubic bezier control points.
List<Offset> quadraticToCubicControls(
        Offset start, Offset control, Offset end) =>
    [
      start * (1 / 3) + control * (2 / 3),
      end * (1 / 3) + control * (2 / 3),
    ];

/// A quadratic bezier segment like [Path.quadraticBezierTo].
class QuadraticSegment extends Segment {
  QuadraticSegment({
    required this.control,
    required this.end,
    String? tag,
  }) : super(
          tag: tag,
        );

  /// The control point of this quadratic bezier segment.
  final Offset control;

  /// The end point of this quadratic bezier segment.
  final Offset end;

  @override
  void drawPath(Path path) =>
      path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

  @override
  QuadraticSegment lerpFrom(covariant QuadraticSegment from, double t) =>
      QuadraticSegment(
        control: Offset.lerp(from.control, control, t)!,
        end: Offset.lerp(from.end, end, t)!,
        tag: tag,
      );

  @override
  CubicSegment toCubic(Offset start) {
    final controls = quadraticToCubicControls(start, control, end);
    return CubicSegment(
      control1: controls.first,
      control2: controls.last,
      end: end,
      tag: tag,
    );
  }

  @override
  QuadraticSegment sow(Offset position) => QuadraticSegment(
        control: position,
        end: position,
        tag: tag,
      );

  @override
  Offset getEnd() => end;

  @override
  bool operator ==(Object other) =>
      other is QuadraticSegment &&
      super == other &&
      control == other.control &&
      end == other.end;
}
