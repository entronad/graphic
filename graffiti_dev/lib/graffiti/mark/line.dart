import 'dart:ui';

import 'mark.dart';

class LineMark extends ShapeMark {
  LineMark({
    required this.start,
    required this.end,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Offset start;

  final Offset end;
  
  @override
  void drawPath(Path path) {
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);
  }
}
