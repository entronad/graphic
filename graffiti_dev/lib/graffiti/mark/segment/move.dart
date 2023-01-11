import 'dart:ui';

import 'segment.dart';

class MoveSegment extends Segment {
  MoveSegment({
    required this.end,
  
    bool relative = false,
  }) : super(
    relative: relative,
  );
  
  final Offset end;

  @override
  void absoluteDrawPath(Path path) =>
    path.moveTo(end.dx, end.dy);
  
  @override
  void relativeDrawPath(Path path) =>
    path.relativeMoveTo(end.dx, end.dy);
}
