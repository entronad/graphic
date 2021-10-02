import 'dart:ui';

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:meta/meta.dart';
import 'package:graphic/src/coord/coord.dart';

abstract class Shape {
  /// To paint the whole group.
  /// The element scene will take the first item shape as represent,
  ///     and it's paintGroup method decides the basic way to paint the wholw group.
  /// It may call each item shape's paintItem to paint different item shapes seperately.
  void paintGroup(
    List<Aes> group,
    CoordConv coord,
    Offset origin,
    Canvas canvas,
  );

  /// How each item is painted exactly.
  @protected
  void paintItem(
    Aes item,
    CoordConv coord,
    Offset origin,
    Canvas canvas,
  );

  @protected
  double get defaultSize;

  /// Usually the last point represent the statistic value.
  Offset representPoint(List<Offset> position) =>
    position.last;

  /// Force subclasses to implement equality.
  /// It will be used in operator ==.
  /// Usually they must be the same subtype and have equal fields.
  @protected
  bool equalTo(Object other);

  @override
  bool operator ==(Object other) =>
    this.equalTo(other);
}
