import 'dart:ui';
import 'dart:math';

import 'segment.dart';
import 'cubic.dart';
import 'arc_to_point.dart';
import '../arc.dart';

class ArcSegment extends Segment {
  ArcSegment({
    required this.oval,
    required this.startAngle,
    required this.endAngle,

    String? tag,
  }) : super(
    tag: tag,
  );

  final Rect oval;

  final double startAngle;

  final double endAngle;

  @override
  void drawPath(Path path) =>
    path.arcTo(oval, startAngle, endAngle - startAngle, false);

  @override
  ArcSegment lerpFrom(covariant ArcSegment from, double t) => ArcSegment(
    oval: Rect.lerp(from.oval, oval, t)!,
    startAngle: lerpDouble(from.startAngle, startAngle, t)!,
    endAngle: lerpDouble(from.endAngle, endAngle, t)!,
    tag: tag,
  );

  @override
  CubicSegment toCubic(Offset start) {
    final sweepAngle = endAngle - startAngle;
    return ArcToPointSegment(
      end: getArcPoint(oval, endAngle),
      radius: Radius.elliptical(oval.width / 2, oval.height / 2),
      largeArc: sweepAngle.abs() % (pi * 2) > pi,
      clockwise: sweepAngle >= 0,
      tag: tag,
    ).toCubic(start);
  }
  
  @override
  ArcSegment sow(Offset position) => ArcSegment(
    oval: Rect.fromCircle(center: position, radius: 0),
    startAngle: startAngle,
    endAngle: endAngle,
    tag: tag,
  );
  
  @override
  Offset getEnd() => getArcPoint(oval, endAngle);
}
