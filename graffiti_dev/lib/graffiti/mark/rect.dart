import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graffiti_dev/graffiti/mark/path.dart';

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

  @override
  RectMark lerpFrom(covariant RectMark from, double t) => RectMark(
    rect: Rect.lerp(from.rect, rect, t)!,
    borderRadius: BorderRadius.lerp(from.borderRadius, borderRadius, t),
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
