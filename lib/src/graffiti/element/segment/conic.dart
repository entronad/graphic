import 'dart:ui';

import 'segment.dart';
import 'quadratic.dart';
import 'cubic.dart';

/// A conic segment like [Path.conicTo].
class ConicSegment extends Segment {
  /// Creates a conic segment.
  ConicSegment({
    required this.control,
    required this.end,
    required this.weight,
    String? tag,
  }) : super(
          tag: tag,
        );

  /// The control point of this conic.
  final Offset control;

  /// The end point of this conic.
  final Offset end;

  /// The weight of this conic.
  final double weight;

  @override
  void drawPath(Path path) =>
      path.conicTo(control.dx, control.dy, end.dx, end.dy, weight);

  @override
  ConicSegment lerpFrom(covariant ConicSegment from, double t) => ConicSegment(
        control: Offset.lerp(from.control, control, t)!,
        end: Offset.lerp(from.end, end, t)!,
        weight: lerpDouble(from.weight, weight, t)!,
        tag: tag,
      );

  @override
  CubicSegment toCubic(Offset start) {
    final middleBase = (start + end) / 2;
    final quadraticControl = Offset.lerp(middleBase, control, weight);
    final controls = quadraticToCubicControls(start, quadraticControl!, end);
    return CubicSegment(
      control1: controls.first,
      control2: controls.last,
      end: end,
      tag: tag,
    );
  }

  @override
  ConicSegment sow(Offset position) => ConicSegment(
        control: position,
        end: position,
        weight: weight,
        tag: tag,
      );

  @override
  Offset getEnd() => end;

  @override
  bool operator ==(Object other) =>
      other is ConicSegment &&
      super == other &&
      control == other.control &&
      end == other.end &&
      weight == other.weight;
}
