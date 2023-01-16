import 'dart:ui';

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
}
