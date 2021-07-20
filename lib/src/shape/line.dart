import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';

import 'shape.dart';
import 'function.dart';

abstract class LineShape extends FunctionShape {
  
}

class BasicLineShape extends LineShape {
  @override
  bool equalTo(Object other) =>
    other is BasicLineShape;

  @override
  void paintGroup(List<Aes> group, CoordConv coord, Canvas canvas) {
    // TODO: implement paintGroup
  }

  @override
  void paintItem(Aes item, CoordConv coord, Canvas canvas) {
    // TODO: implement paintItem
  }
}
