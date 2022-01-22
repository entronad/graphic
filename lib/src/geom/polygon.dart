import 'dart:async';
import 'dart:ui';

import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/shape/polygon.dart';

import 'partition.dart';
import 'modifier/modifier.dart';

/// The specification of a polygon element.
///
/// A polygon graphing can tile a surface or space, filling the space with mutually
/// exclusive polygons.
///
/// It will check and complete position points by the rule of:
///
/// ```
/// [point] => [point]
/// ```
class PolygonElement extends PartitionElement<PolygonShape> {
  /// Creates a polygon element.
  PolygonElement({
    ColorAttr? color,
    ElevationAttr? elevation,
    GradientAttr? gradient,
    LabelAttr? label,
    Varset? position,
    ShapeAttr<PolygonShape>? shape,
    SizeAttr? size,
    List<Modifier>? modifiers,
    int? layer,
    Selected? selected,
    StreamController<Selected?>? selectionChannel,
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
          selectionChannel: selectionChannel,
        );
}

/// The position completer of the polygon element.
///
/// It will check and complete position points by the rule of:
///
/// ```
/// [point] => [point]
/// ```
List<Offset> polygonCompleter(List<Offset> position, Offset origin) {
  assert(position.length == 1);
  return position;
}
