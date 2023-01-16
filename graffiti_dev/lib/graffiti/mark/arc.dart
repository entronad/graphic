import 'dart:ui';

import 'mark.dart';

class ArcMark extends ShapeMark {
  ArcMark({
    required this.oval,
    required this.startAngle,
    required this.endAngle,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Rect oval;

  final double startAngle;

  final double endAngle;
  
  @override
  void drawPath(Path path) =>
    path.addArc(oval, startAngle, endAngle - startAngle);
}
