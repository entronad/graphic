import 'dart:async';
import 'dart:ui';

import 'package:graphic/src/encode/color.dart';
import 'package:graphic/src/encode/elevation.dart';
import 'package:graphic/src/encode/gradient.dart';
import 'package:graphic/src/encode/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/encode/shape.dart';
import 'package:graphic/src/encode/size.dart';
import 'package:graphic/src/graffiti/transition.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/shape/interval.dart';

import 'function.dart';
import 'modifier/modifier.dart';
import 'mark.dart';

/// The specification of an interval mark.
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
class IntervalMark extends FunctionMark<IntervalShape> {
  /// Creates an interval mark.
  IntervalMark({
    ColorEncode? color,
    ElevationEncode? elevation,
    GradientEncode? gradient,
    LabelEncode? label,
    Varset? position,
    ShapeEncode<IntervalShape>? shape,
    SizeEncode? size,
    List<Modifier>? modifiers,
    int? layer,
    Selected? selected,
    StreamController<Selected?>? selectionStream,
    Transition? transition,
    MarkEntrance? entrance,
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
          selectionStream: selectionStream,
          transition: transition,
          entrance: entrance,
        );
}

/// The position completer of the interval mark.
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
