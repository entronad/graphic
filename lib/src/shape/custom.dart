import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';

import 'shape.dart';

abstract class CustomShape extends Shape {
  
}

class CandlestickShape extends CustomShape {
  @override
  bool equalTo(Object other) =>
    other is CandlestickShape;

  @override
  void paintGroup(List<Aes> group, CoordConv coord, Canvas canvas) {
    // TODO: implement paintGroup
  }

  @override
  void paintItem(Aes item, CoordConv coord, Canvas canvas) {
    // TODO: implement paintItem
  }
}
