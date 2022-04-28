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
import 'package:graphic/src/shape/shape.dart';

import 'element.dart';
import 'modifier/modifier.dart';

/// The specification of a custom element.
///
/// A custom element has no special graphing rule. It accepts any built-in or custom
/// [Shape]s.
///
/// It will not check or complete the position points.
class CustomElement extends GeomElement<Shape> {
  /// Creates a custom element.
  CustomElement({
    ColorAttr? color,
    ElevationAttr? elevation,
    GradientAttr? gradient,
    LabelAttr? label,
    Varset? position,
    ShapeAttr<Shape>? shape,
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

/// The position completer of the custom element.
///
/// It will return the [position] directly.
List<Offset> customCompleter(List<Offset> position, Offset origin) => position;
