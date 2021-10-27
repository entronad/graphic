import 'dart:ui';

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:flutter/foundation.dart';
import 'package:graphic/src/coord/coord.dart';

/// The Base class of a shape.
///
/// A shape renders figures of tuples from their aesthetic attribute values. It is
/// the key of painting geometory elements. Besides, the shape it self is an aesthetic
/// attribute in Grammar of Graphics.
///
/// Customizing subclasses of shape extenses chart types.
abstract class Shape {
  /// Renders the whole group of tuples.
  ///
  /// The tuples are rendered in groups. the [Aes.shape] of the first tuple of a
  /// group will be taken as a represent, and it's [renderGroup] method decides
  /// the basic way to render the whole group. The [renderGroup] method then may
  /// call [renderItem]s of each tuple of the group respectively or render in it's
  /// own way accrording to the implementation.
  List<Figure> renderGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
  );

  /// Renders a single tuple if called by [renderGroup].
  @protected
  List<Figure> renderItem(
    Aes item,
    CoordConv coord,
    Offset origin,
  );

  /// The default size of the shape if [Aes.size] is null.
  @protected
  double get defaultSize;

  /// Gets the represent point of [Aes.position] points.
  ///
  /// It is callen by [Aes.representPoint].
  ///
  /// Usually the represent point is the last one.
  Offset representPoint(List<Offset> position) => position.last;

  /// Checks the equlity of two shapes.
  ///
  /// Because the shape is a functional class in design, they should be equal if
  /// they are of the same type and has same properties.
  ///
  /// It is used by [==]. This method forces a equlity definition in customizing.
  @protected
  bool equalTo(Object other);

  @override
  bool operator ==(Object other) => this.equalTo(other);
}
