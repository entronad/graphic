import 'dart:ui';

import 'segment.dart';

class LineSegment extends Segment {
  LineSegment({
    required this.end,
  
    bool relative = false,
  }) : super(
    relative: relative,
  );

  final Offset end;
  
  @override
  void absoluteDrawPath(Path path) =>
    path.lineTo(end.dx, end.dy);
  
  @override
  void relativeDrawPath(Path path) =>
    path.relativeLineTo(end.dx, end.dy);
}
