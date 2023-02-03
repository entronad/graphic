import 'dart:ui';

import 'segment.dart';
import 'cubic.dart';

class MoveSegment extends Segment {
  MoveSegment({
    required this.end,
  
    String? id,
  }) : super(
    id: id,
  );
  
  final Offset end;

  @override
  void drawPath(Path path) =>
    path.moveTo(end.dx, end.dy);

  @override
  MoveSegment lerpFrom(covariant MoveSegment from, double t) => MoveSegment(
    end: Offset.lerp(from.end, end, t)!,
    id: id,
  );

  @override
  CubicSegment toCubic(Offset start) {
    throw UnsupportedError('Move segment can not be converted to cubic.');
  }
}
