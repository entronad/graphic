import 'dart:ui';

import 'segment.dart';

class CubicSegment extends Segment {
  CubicSegment({
    required this.control1,
    required this.control2,
    required this.end,
    String? tag,
  }) : super(
          tag: tag,
        );

  final Offset control1;

  final Offset control2;

  final Offset end;

  @override
  void drawPath(Path path) => path.cubicTo(
      control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy);

  @override
  CubicSegment lerpFrom(covariant CubicSegment from, double t) => CubicSegment(
        control1: Offset.lerp(from.control1, control1, t)!,
        control2: Offset.lerp(from.control2, control2, t)!,
        end: Offset.lerp(from.end, end, t)!,
        tag: tag,
      );

  @override
  CubicSegment toCubic(Offset start) => this;

  @override
  CubicSegment sow(Offset position) => CubicSegment(
        control1: position,
        control2: position,
        end: position,
        tag: tag,
      );

  @override
  Offset getEnd() => end;

  @override
  bool operator ==(Object other) =>
      other is CubicSegment &&
      super == other &&
      control1 == other.control1 &&
      control2 == other.control2 &&
      end == other.end;
}
