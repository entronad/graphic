import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/aes/position.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';

import 'geom_element.dart';
import 'modifier/modifier.dart';

abstract class FunctionElement extends GeomElement {
  FunctionElement({
    ColorAttr? color,
    ElevationAttr? elevation,
    GradientAttr? gradient,
    LabelAttr? label,
    PositionAttr? position,
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
