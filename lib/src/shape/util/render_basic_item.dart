import 'dart:ui';

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/element/element.dart';

PaintStyle getPaintStyle(
  Attributes attributes,
  bool hollow,
  double strokeWidth, [
  Rect? gradientBounds,
]) {
  if (hollow) {
    if (attributes.gradient != null) {
      return PaintStyle(strokeGradient: attributes.gradient, strokeWidth: strokeWidth, elevation: attributes.elevation, gradientBounds: gradientBounds);
    } else {
      return PaintStyle(strokeColor: attributes.color, strokeWidth: strokeWidth, elevation: attributes.elevation, gradientBounds: gradientBounds);
    }
  } else {
    if (attributes.gradient != null) {
      return PaintStyle(fillGradient: attributes.gradient, elevation: attributes.elevation, gradientBounds: gradientBounds);
    } else {
      return PaintStyle(fillColor: attributes.color, elevation: attributes.elevation, gradientBounds: gradientBounds);
    }
  }
}
