import 'dart:ui';

import 'package:graphic/src/algebra/varset.dart';

import 'base.dart';

class PositionAttr extends Attr<List<Offset>> {
  PositionAttr({
    required this.algebra,
  });

  final Varset algebra;
}
