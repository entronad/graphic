import 'dart:ui';

import 'mark.dart';

class PolygonMark extends ShapeMark {
  PolygonMark({
    required this.points,
    required this.close,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final List<Offset> points;

  final bool close;
  
  @override
  void drawPath(Path path) {
    path.moveTo(points[0].dx, points[0].dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    if (close) {
      path.close();
    }
  }
}
