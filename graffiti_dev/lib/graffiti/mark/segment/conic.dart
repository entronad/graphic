import 'dart:ui';

import 'segment.dart';

class ConicSegment extends Segment {
  ConicSegment({
    required this.control,
    required this.end,
    required this.weight,
  
    bool relative = false,
  }) : super(
    relative: relative,
  );

  final Offset control;

  final Offset end;

  final double weight;
  
  @override
  void absoluteDrawPath(Path path) =>
    path.conicTo(control.dx, control.dy, end.dx, end.dy, weight);
  
  @override
  void relativeDrawPath(Path path) =>
    path.relativeConicTo(control.dx, control.dy, end.dx, end.dy, weight);
}
