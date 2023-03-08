import 'dart:ui';

import 'segment.dart';
import 'quadratic.dart';
import 'cubic.dart';

class ConicSegment extends Segment {
  ConicSegment({
    required this.control,
    required this.end,
    required this.weight,
    String? tag,
  }) : super(
          tag: tag,
        );

  final Offset control;

  final Offset end;

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
}
