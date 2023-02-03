import 'dart:ui';

import 'segment.dart';
import 'cubic.dart';

class LineSegment extends Segment {
  LineSegment({
    required this.end,
  
    String? id,
  }) : super(
    id: id,
  );

  final Offset end;
  
  @override
  void drawPath(Path path) =>
    path.lineTo(end.dx, end.dy);

  @override
  LineSegment lerpFrom(covariant LineSegment from, double t) => LineSegment(
    end: Offset.lerp(from.end, end, t)!,
    id: id,
  );

  @override
  CubicSegment toCubic(Offset start) {
    const t = 0.5;
    final p2 = Offset.lerp(start, end, t);
    final p3 = Offset.lerp(end, p2, t);
    final p4 = Offset.lerp(p2, p3, t);
    final p5 = Offset.lerp(p3, p4, t);
    final p6 = Offset.lerp(p4, p5, t);

    return CubicSegment(
      control1: Offset.lerp(start, p2, p4!.dx / ((start - p2!).distance))!,
      control2: Offset.lerp(p6, p5, p3!.dx / ((p6! - p5!).distance))!,
      end: end,
      id: id,
    );
  }
}
