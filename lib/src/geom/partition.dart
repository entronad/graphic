import 'package:graphic/src/aes/color.dart';
import 'package:graphic/src/aes/elevation.dart';
import 'package:graphic/src/aes/gradient.dart';
import 'package:graphic/src/aes/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/aes/shape.dart';
import 'package:graphic/src/aes/size.dart';
import 'package:graphic/src/shape/partition.dart';

import 'element.dart';
import 'modifier/modifier.dart';

/// The specification of a partition element.
///
/// Partitions separete a set of points into two or more subsets.
abstract class PartitionElement<S extends PartitionShape>
    extends GeomElement<S> {
  /// Creates a partition element.
  PartitionElement({
    ColorAttr? color,
    ElevationAttr? elevation,
    GradientAttr? gradient,
    LabelAttr? label,
    Varset? position,
    ShapeAttr<S>? shape,
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
