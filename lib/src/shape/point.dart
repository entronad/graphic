import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';

import 'shape.dart';
import 'function.dart';

abstract class PointShape extends FunctionShape {
  
}

class CircleShape extends PointShape {
  @override
  bool equalTo(Object other) =>
    other is CircleShape;

  @override
  void paintGroup(List<Aes> group, CoordConv coord, Canvas canvas) {
    // TODO: implement paintGroup
  }

  @override
  void paintItem(Aes item, CoordConv coord, Canvas canvas) {
    // TODO: implement paintItem
  }
}

class SquareShape extends PointShape {
  @override
  bool equalTo(Object other) =>
    other is SquareShape;

  @override
  void paintGroup(List<Aes> group, CoordConv coord, Canvas canvas) {
    // TODO: implement paintGroup
  }

  @override
  void paintItem(Aes item, CoordConv coord, Canvas canvas) {
    // TODO: implement paintItem
  }
}
