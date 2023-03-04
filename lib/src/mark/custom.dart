import 'dart:async';
import 'dart:ui';

import 'package:graphic/src/encode/color.dart';
import 'package:graphic/src/encode/elevation.dart';
import 'package:graphic/src/encode/gradient.dart';
import 'package:graphic/src/encode/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/encode/shape.dart';
import 'package:graphic/src/encode/size.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/shape/shape.dart';

import 'mark.dart';
import 'modifier/modifier.dart';

/// The specification of a custom mark.
///
/// A custom mark has no special graphing rule. It accepts any built-in or custom
/// [Shape]s.
///
/// It will not check or complete the position points.
class CustomMark extends Mark<Shape> {
  /// Creates a custom mark.
  CustomMark({
    ColorEncode? color,
    ElevationEncode? elevation,
    GradientEncode? gradient,
    LabelEncode? label,
    Varset? position,
    ShapeEncode<Shape>? shape,
    SizeEncode? size,
    List<Modifier>? modifiers,
    int? layer,
    Selected? selected,
    StreamController<Selected?>? selectionStream,
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
        );
}

/// The position completer of the custom mark.
///
/// It will return the [position] directly.
List<Offset> customCompleter(List<Offset> position, Offset origin) => position;
