import 'dart:ui';

import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';
import 'package:graphic/src/shape/line.dart';

import 'function.dart';
import 'modifier/modifier.dart';

/// The specification of a line element.
///
/// A line graphing visits all points and connets all points with a line. Note this
/// definition is more like the *path* in the Grammer of Graphics.
///
/// It will check and complete position points by the rule of:
///
/// ```
/// [point] => [point]
/// ```
class LineElement extends FunctionElement<LineShape> {
  /// Creates a line element.
  LineElement({
    ColorAttr? color,
    ElevationAttr? elevation,
    GradientAttr? gradient,
    LabelAttr? label,
    Varset? position,
    ShapeAttr<LineShape>? shape,
    SizeAttr? size,
    List<Modifier>? modifiers,
    int? layer,
    Map<String, Set<int>>? selected,
    void Function(Map<String, Set<int>>)? onSelection,
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
          onSelection: onSelection,
        );
}

/// The position completer of the line element.
///
/// It will check and complete position points by the rule of:
///
/// ```
/// [point] => [point]
/// ```
List<Offset> lineCompleter(List<Offset> position, Offset origin) {
  assert(position.length == 1);
  return position;
}
