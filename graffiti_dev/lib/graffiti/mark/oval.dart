import 'dart:ui';

import 'mark.dart';

class OvalMark extends ShapeMark {
  OvalMark({
    required this.oval,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Rect oval;
  
  @override
  void drawPath(Path path) =>
    path.addOval(oval);
}
