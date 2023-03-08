import 'dart:async';

import 'package:graphic/src/encode/color.dart';
import 'package:graphic/src/encode/elevation.dart';
import 'package:graphic/src/encode/gradient.dart';
import 'package:graphic/src/encode/label.dart';
import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/encode/shape.dart';
import 'package:graphic/src/encode/size.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/shape/partition.dart';

import 'mark.dart';
import 'modifier/modifier.dart';

/// The specification of a partition mark.
///
/// Partitions separete a set of points into two or more subsets.
abstract class PartitionMark<S extends PartitionShape> extends Mark<S> {
  /// Creates a partition mark.
  PartitionMark({
    ColorEncode? color,
    ElevationEncode? elevation,
    GradientEncode? gradient,
    LabelEncode? label,
    Varset? position,
    ShapeEncode<S>? shape,
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
