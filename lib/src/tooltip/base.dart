import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:graphic/src/common/styles.dart';

class Crosshair {
  Crosshair({
    this.style,
    this.followPointer,
  });

  final StrokeStyle? style;

  final bool? followPointer;

  @override
  bool operator ==(Object other) =>
    other is Crosshair &&
    style == other.style &&
    followPointer == other.followPointer;
}

class Tooltip {
  Tooltip({
    this.selection,
    this.variables,
    this.followPointer,
    this.offset,
    this.crosshairs,
    this.size,
    this.backgroundColor,
    this.radius,
    this.textStyle,
  });

  /// The selection must:
  ///     Be a PointSelection.
  ///     Toggle is false.
  ///     Variables less than 1.
  final String? selection;

  /// Variables to show.
  /// Default to show all.
  final List<String>? variables;

  final bool? followPointer;

  final Offset? offset;

  /// Crosshair of each dim.
  final List<Crosshair?>? crosshairs;

  final Size? size;

  final Color? backgroundColor;

  final Radius? radius;

  final TextStyle? textStyle;

  @override
  bool operator ==(Object other) =>
    other is Tooltip &&
    selection == other.selection &&
    DeepCollectionEquality().equals(variables, other.variables) &&
    followPointer == other.followPointer &&
    offset == other.offset &&
    DeepCollectionEquality().equals(crosshairs, other.crosshairs) &&
    size == other.size &&
    backgroundColor == other.backgroundColor &&
    radius == other.radius &&
    textStyle == other.textStyle;
}
