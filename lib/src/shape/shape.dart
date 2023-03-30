import 'dart:ui';

import 'package:graphic/src/common/customizable_spec.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/mark/custom.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:flutter/foundation.dart';
import 'package:graphic/src/coord/coord.dart';

/// The Base class of a shape.
///
/// A shape renders elements of tuples from their aesthetic encode values. It is
/// the key of painting geometry marks. Besides, the shape it self is an aesthetic
/// encode in Grammar of Graphics.
///
/// Shapes could be customized by extending its subclasses of different geometory
/// types, or directly extend this class for the [CustomMark]. Customizing shapes
/// extenses chart types.
abstract class Shape extends CustomizableSpec {
  /// Renders primitive elements of all tuples of a group.
  ///
  /// The tuples are rendered in groups. the [Attributes.shape] of the first tuple of a
  /// group will be taken as a represent, and it's [drawGroupPrimitives] method decides
  /// the basic way to render the whole group. If different tuples have different
  /// shapes, define and call special element rendering methods for each item.
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  );

  /// Renders label elements of all tuples of a group.
  List<MarkElement> drawGroupLabels(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  );

  /// The default size of the shape if [Attributes.size] is null.
  @protected
  double get defaultSize;

  /// Gets the represent point of [Attributes.position] points.
  ///
  /// It is callen by [Attributes.representPoint].
  ///
  /// Usually the represent point is the last one.
  Offset representPoint(List<Offset> position) => position.last;
}
