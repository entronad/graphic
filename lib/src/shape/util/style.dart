import 'dart:ui';

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/element/element.dart';

PaintStyle getPaintStyle(
  Attributes attributes,
  bool hollow,
  double strokeWidth,
  Rect? gradientBounds,
  List<double>? dash,
) {
  if (hollow) {
    if (attributes.gradient != null) {
      return PaintStyle(
        strokeGradient: attributes.gradient,
        strokeWidth: strokeWidth,
        elevation: attributes.elevation,
        gradientBounds: gradientBounds,
        dash: dash,
      );
    } else {
      return PaintStyle(
        strokeColor: attributes.color,
        strokeWidth: strokeWidth,
        elevation: attributes.elevation,
        gradientBounds: gradientBounds,
        dash: dash,
      );
    }
  } else {
    if (attributes.gradient != null) {
      return PaintStyle(
        fillGradient: attributes.gradient,
        elevation: attributes.elevation,
        gradientBounds: gradientBounds,
        dash: dash,
      );
    } else {
      return PaintStyle(
        fillColor: attributes.color,
        elevation: attributes.elevation,
        gradientBounds: gradientBounds,
        dash: dash,
      );
    }
  }
}
