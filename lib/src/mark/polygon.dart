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
import 'package:graphic/src/shape/polygon.dart';

import 'partition.dart';
import 'modifier/modifier.dart';
import 'mark.dart';

/// The specification of a polygon mark.
///
/// A polygon graphing can tile a surface or space, filling the space with mutually
/// exclusive polygons.
///
/// It will check and complete position points by the rule of:
///
/// ```
/// [point] => [point]
/// ```
class PolygonMark extends PartitionMark<PolygonShape> {
  /// Creates a polygon mark.
  PolygonMark({
    ColorEncode? color,
    ElevationEncode? elevation,
    GradientEncode? gradient,
    LabelEncode? label,
    Varset? position,
    ShapeEncode<PolygonShape>? shape,
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

/// The position completer of the polygon mark.
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
