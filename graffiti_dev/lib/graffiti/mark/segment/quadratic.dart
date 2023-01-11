import 'dart:ui';

import 'segment.dart';

class QuadraticSegment extends Segment {
  QuadraticSegment({
    required this.control,
    required this.end,

    bool relative = false,
  }) : super(
    relative: relative,
  );

  final Offset control;

  final Offset end;
  
  @override
  void absoluteDrawPath(Path path) =>
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
  
  @override
  void relativeDrawPath(Path path) =>
    path.relativeQuadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
}
