import 'package:flutter/painting.dart';

import 'mark.dart';

class RectMark extends ShapeMark {
  RectMark({
    required this.rect,
    this.borderRadius,

    required ShapeStyle style,
    double? rotation,
    Offset? rotationAxis,
  }) : super(
    style: style,
    rotation: rotation,
    rotationAxis: rotationAxis,
  );

  final Rect rect;

  final BorderRadius? borderRadius;
  
  @override
  void drawPath(Path path) {
    if (borderRadius == null || borderRadius == BorderRadius.zero) {
      path.addRect(rect);
    } else {
      path.addRRect(borderRadius!.toRRect(rect));
    }
  }
}
