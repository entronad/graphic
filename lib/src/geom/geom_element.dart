import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/aes/position.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';

import 'modifier/modifier.dart';

abstract class GeomElement {
  GeomElement({
    this.color,
    this.elevation,
    this.gradient,
    this.label,
    this.position,
    this.shape,
    this.size,
    this.modifier,
    this.zIndex,
  });

  final ColorAttr? color;

  final ElevationAttr? elevation;

  final GradientAttr? gradient;

  final LabelAttr? label;

  final PositionAttr? position;

  final ShapeAttr? shape;

  final SizeAttr? size;

  final Modifier? modifier;

  final int? zIndex;

  @override
  bool operator ==(Object other) =>
    other is GeomElement &&
    color == other.color &&
    elevation == other.elevation &&
    gradient == other.gradient &&
    label == other.label &&
    position == other.position &&
    shape == other.shape &&
    size == other.size &&
    modifier == modifier &&
    zIndex == other.zIndex;
}
