import 'dart:ui';

import 'segment.dart';

class CubicSegment extends Segment {
  CubicSegment({
    required this.control1,
    required this.control2,
    required this.end,
  
    bool relative = false,
  }) : super(
    relative: relative,
  );

  final Offset control1;

  final Offset control2;

  final Offset end;
  
  @override
  void absoluteDrawPath(Path path) =>
    path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy);
  
  @override
  void relativeDrawPath(Path path) =>
    path.relativeCubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy);
}
