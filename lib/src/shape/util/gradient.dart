import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Transform alignment definition of painting gradient to specific point.
Offset _toPoint(AlignmentGeometry align, Rect region) {
  // Only Alignment is allowed for graphic gradient properties.
  final al = align as Alignment;

  return Offset(
    (region.width / (1 - (-1))) * (al.x - (-1)) + region.left,
    (region.height / (1 - (-1))) * (al.y - (-1)) + region.top,
  );
}

/// Converts a painting gradient to ui gradient.
///
/// Specifications use painting gradient for relative distribution, while canvas
/// needs ui gradient as shader.
ui.Gradient toUIGradient(
  Gradient gradient,
  Rect region,
) {
  if (gradient is LinearGradient) {
    return ui.Gradient.linear(
      _toPoint(gradient.begin, region),
      _toPoint(gradient.end, region),
      gradient.colors,
      gradient.stops,
      gradient.tileMode,
      gradient.transform?.transform(region)?.storage,
    );
  } else if (gradient is RadialGradient) {
    return ui.Gradient.radial(
      _toPoint(gradient.center, region),
      gradient.radius * region.shortestSide,
      gradient.colors,
      gradient.stops,
      gradient.tileMode,
      gradient.transform?.transform(region)?.storage,
      gradient.focal == null ? null : _toPoint(gradient.focal!, region),
      gradient.focalRadius * region.shortestSide,
    );
  } else if (gradient is SweepGradient) {
    return ui.Gradient.sweep(
      _toPoint(gradient.center, region),
      gradient.colors,
      gradient.stops,
      gradient.tileMode,
      gradient.startAngle,
      gradient.endAngle,
      gradient.transform?.transform(region)?.storage,
    );
  }
  throw ArgumentError('Iillegal gradient type.');
}

/// Calculates shadow color of a graphic with gradient.
Color getShadowColor(Gradient gradient) {
  if (gradient is LinearGradient) {
    return Color.lerp(
      gradient.colors.first,
      gradient.colors.last,
      0.5,
    )!;
  } else if (gradient is RadialGradient) {
    return gradient.colors.last;
  } else if (gradient is SweepGradient) {
    return Color.lerp(
      gradient.colors.first,
      gradient.colors.last,
      0.5,
    )!;
  }
  throw ArgumentError('Iillegal gradient type.');
}
