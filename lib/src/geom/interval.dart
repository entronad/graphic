import 'dart:ui';

import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';

import 'function.dart';
import 'modifier/modifier.dart';

class IntervalElement extends FunctionElement {
  IntervalElement({
    ColorAttr? color,
    ElevationAttr? elevation,
    GradientAttr? gradient,
    LabelAttr? label,
    Varset? position,
    ShapeAttr? shape,
    SizeAttr? size,
    Modifier? modifier,
    int? zIndex,
  }) : super(
    color: color,
    elevation: elevation,
    gradient: gradient,
    label: label,
    position: position,
    shape: shape,
    size: size,
    modifier: modifier,
    zIndex: zIndex,
  );
}

/// [start, end] | [end] => [start, end]
List<Offset> IntervalCompleter(List<Offset> position, Offset origin) {
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
