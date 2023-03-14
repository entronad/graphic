import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Transform alignment definition of painting gradient to specific point.
Offset _toPoint(AlignmentGeometry align, Rect bounds) {
  // Only Alignment is allowed for graphic gradient properties.
  final al = align as Alignment;

  return Offset(
    (bounds.width / (1 - (-1))) * (al.x - (-1)) + bounds.left,
    (bounds.height / (1 - (-1))) * (al.y - (-1)) + bounds.top,
  );
}

/// Converts a painting gradient to ui gradient.
///
/// Specifications use painting gradient for relative distribution, while canvas
/// needs ui gradient as shader.
ui.Gradient toUiGradient(
  Gradient gradient,
  Rect bounds,
) {
  if (gradient is LinearGradient) {
    return ui.Gradient.linear(
      _toPoint(gradient.begin, bounds),
      _toPoint(gradient.end, bounds),
      gradient.colors,
      gradient.stops,
      gradient.tileMode,
      gradient.transform?.transform(bounds)?.storage,
    );
  } else if (gradient is RadialGradient) {
    return ui.Gradient.radial(
      _toPoint(gradient.center, bounds),
      gradient.radius * bounds.shortestSide,
      gradient.colors,
      gradient.stops,
      gradient.tileMode,
      gradient.transform?.transform(bounds)?.storage,
      gradient.focal == null ? null : _toPoint(gradient.focal!, bounds),
      gradient.focalRadius * bounds.shortestSide,
    );
  } else if (gradient is SweepGradient) {
    return ui.Gradient.sweep(
      _toPoint(gradient.center, bounds),
      gradient.colors,
      gradient.stops,
      gradient.tileMode,
      gradient.startAngle,
      gradient.endAngle,
      gradient.transform?.transform(bounds)?.storage,
    );
  }
  throw ArgumentError('Iillegal gradient type.');
}
