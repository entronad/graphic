import 'dart:ui';

import 'segment.dart';

class CubicSegment extends Segment {
  CubicSegment({
    required this.control1,
    required this.control2,
    required this.end,
  
    String? id,
  }) : super(
    id: id,
  );

  final Offset control1;

  final Offset control2;

  final Offset end;
  
  @override
  void drawPath(Path path) =>
    path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, end.dx, end.dy);
    
  @override
  CubicSegment lerpFrom(covariant CubicSegment from, double t) => CubicSegment(
    control1: Offset.lerp(from.control1, control1, t)!,
    control2: Offset.lerp(from.control2, control2, t)!,
    end: Offset.lerp(from.end, end, t)!,
    id: id,
  );
    
  @override
  CubicSegment toCubic(Offset start) => this;
}
