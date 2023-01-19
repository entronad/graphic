import 'dart:ui';

import 'package:graffiti_dev/graffiti/mark/path.dart';

import 'mark.dart';

class CircleMark extends ShapeMark {
  CircleMark({
    required this.center,
    required this.radius,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Offset center;

  final double radius;
  
  @override
  void drawPath(Path path) =>
    path.addOval(Rect.fromCircle(center: center, radius: radius));

  @override
  CircleMark lerpFrom(covariant CircleMark from, double t) => CircleMark(
    center: Offset.lerp(from.center, center, t)!,
    radius: lerpDouble(from.radius, radius, t)!,
    style: style.lerpFrom(from.style, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    rotationAxis: Offset.lerp(from.rotationAxis, rotationAxis, t),
  );

  @override
  PathMark toBezier() {
    // TODO: implement toBezier
    throw UnimplementedError();
  }
}
