import 'dart:ui';

import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';
import 'package:graphic/src/shape/point.dart';

import 'function.dart';
import 'modifier/modifier.dart';

class PointElement extends FunctionElement<PointShape> {
  PointElement({
    ColorAttr? color,
    ElevationAttr? elevation,
    GradientAttr? gradient,
    LabelAttr? label,
    Varset? position,
    ShapeAttr<PointShape>? shape,
    SizeAttr? size,
    List<Modifier>? modifiers,
    int? zIndex,
    String? groupBy,
    Map<String, Set<int>>? selected,
  }) : super(
    color: color,
    elevation: elevation,
    gradient: gradient,
    label: label,
    position: position,
    shape: shape,
    size: size,
    modifiers: modifiers,
    zIndex: zIndex,
    groupBy: groupBy,
    selected: selected,
  );
}

/// [point] => [point]
List<Offset> pointCompleter(List<Offset> position, Offset origin) {
  assert(position.length == 1);
  return position;
}
