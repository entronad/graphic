import 'dart:ui';

import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';
import 'package:graphic/src/shape/interval.dart';

import 'function.dart';
import 'modifier/modifier.dart';

/// The specification of an interval element.
///
/// An interval graphing produces a set of closed intervals with two ends.
///
/// It covers a lot types of triditional chart typologies, such as bar, histogram,
/// pie, rose, etc.
///
/// It will check and complete position points by the rule of:
///
/// ```
/// [start, end] | [end] => [start, end]
/// ```
class IntervalElement extends FunctionElement<IntervalShape> {
  /// Creates an interval element.
  IntervalElement({
    ColorAttr? color,
    ElevationAttr? elevation,
    GradientAttr? gradient,
    LabelAttr? label,
    Varset? position,
    ShapeAttr<IntervalShape>? shape,
    SizeAttr? size,
    List<Modifier>? modifiers,
    int? layer,
    Map<String, Set<int>>? selected,
    void Function(Map<String, Set<int>>)? onSelection,
  }) : super(
          color: color,
          elevation: elevation,
          gradient: gradient,
          label: label,
          position: position,
          shape: shape,
          size: size,
          modifiers: modifiers,
          layer: layer,
          selected: selected,
          onSelection: onSelection,
        );
}

/// The position completer of the interval element.
///
/// It will check and complete position points by the rule of:
///
/// ```
/// [start, end] | [end] => [start, end]
/// ```
List<Offset> intervalCompleter(List<Offset> position, Offset origin) {
  assert(position.length == 1 || position.length == 2);
  if (position.length == 1) {
    final normalZero = origin.dy;
    final end = position.first;
    return [
      Offset(end.dx, normalZero),
      end,
    ];
  }
  return position;
}
