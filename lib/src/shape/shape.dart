import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/coord/coord.dart';

class Aes {
  Aes({
    required this.color,
    required this.elevation,
    required this.gradient,
    required this.label,
    required this.position,
    required this.shape,
    required this.size,
  });

  final Color color;

  final double elevation;

  final Gradient gradient;

  final TextSpan label;

  final List<Offset> position;

  final Shape shape;

  final double size;
}

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
  void paintItem(
    Aes item,
    CoordConv coord,
    Canvas canvas,
  );

  /// Force subclasses to implement equality.
  /// It will be used in operator ==.
  /// Usually they must be the same subtype and have equal fields.
  bool equalTo(Object other);

  @override
  bool operator ==(Object other) =>
    this.equalTo(other);
}
