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

class LineElement extends FunctionElement {
  LineElement({
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

/// [point] => [point]
List<Offset> LineCompleter(List<Offset> position, Offset origin) {
  assert(position.length == 1);
  return position;
}
