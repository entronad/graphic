import 'dart:ui';
import 'dart:math';

import 'element.dart';
import 'segment/segment.dart';
import 'segment/move.dart';
import 'segment/arc.dart';

Offset getArcPoint(Rect oval, double angle) {
  // https://blog.csdn.net/chenlu5201314/article/details/99678398

  final a = oval.width / 2;
  final b = oval.height / 2;
  final yc = sin(angle);
  final xc = cos(angle);
  final radio = (a * b) / sqrt(pow(yc * a, 2) + pow(xc * b, 2));

  return oval.center.translate(radio * xc, radio * yc);
}

class ArcElement extends ShapeElement {
  ArcElement({
    required this.oval,
    required this.startAngle,
    required this.endAngle,

    ShapeStyle? style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style ?? defaultShapeStyle,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Rect oval;

  final double startAngle;

  final double endAngle;
  
  @override
  void drawPath(Path path) =>
    path.addArc(oval, startAngle, endAngle - startAngle);

  @override
  ArcElement lerpFrom(covariant ArcElement from, double t) => ArcElement(
    oval: Rect.lerp(from.oval, oval, t)!,
    startAngle: lerpDouble(from.startAngle, startAngle, t)!,
    endAngle: lerpDouble(from.endAngle, endAngle, t)!,
    style: style.lerpFrom(from.style, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
  );

  @override
  List<Segment> toSegments() => [
    MoveSegment(end: getArcPoint(oval, startAngle)),
    ArcSegment(oval: oval, startAngle: startAngle, endAngle: endAngle, tag: SegmentTags.top),
  ];
}
