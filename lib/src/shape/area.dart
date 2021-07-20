import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';

import 'shape.dart';
import 'function.dart';

abstract class AreaShape extends FunctionShape {
  
}

class BasicAreaShape extends AreaShape {
  @override
  bool equalTo(Object other) =>
    other is BasicAreaShape;

  @override
  void paintGroup(List<Aes> group, CoordConv coord, Canvas canvas) {
    // TODO: implement paintGroup
  }

  @override
  void paintItem(Aes item, CoordConv coord, Canvas canvas) {
    // TODO: implement paintItem
  }
}
