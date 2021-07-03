import 'dart:ui';

import 'package:graphic/src/algebra/varset.dart';

import 'attr.dart';

class PositionAttr extends Attr<List<Offset>> {
  PositionAttr({
    required this.algebra,
  });

  final Varset algebra;

  @override
  bool operator ==(Object other) =>
    other is PositionAttr &&
    super == other &&
    algebra == other.algebra;
}
