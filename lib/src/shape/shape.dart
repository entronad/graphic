import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/coord/coord.dart';

abstract class Shape {
  /// To paint the whole group.
  /// The element scene will take the first item shape as represent,
  ///     and it's paintGroup method decides the basic way to paint the wholw group.
  /// It may call each item shape's paintItem to paint different item shapes seperately.
  void paintGroup(
    List<Aes> group,
    CoordConv coord,
    Canvas canvas,
  );

  /// How each item is painted exactly.
  @protected
  void paintItem(
    Aes item,
    CoordConv coord,
    Canvas canvas,
  );

  @protected
  double get defaultSize;

  /// Force subclasses to implement equality.
  /// It will be used in operator ==.
  /// Usually they must be the same subtype and have equal fields.
  @protected
  bool equalTo(Object other);

  @override
  bool operator ==(Object other) =>
    this.equalTo(other);
}
