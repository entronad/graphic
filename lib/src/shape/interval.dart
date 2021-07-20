import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';

import 'shape.dart';
import 'function.dart';

abstract class IntervalShape extends FunctionShape {
  
}

class BarShape extends IntervalShape {
  @override
  bool equalTo(Object other) =>
    other is BarShape;

  @override
  void paintGroup(List<Aes> group, CoordConv coord, Canvas canvas) {
    // TODO: implement paintGroup
  }

  @override
  void paintItem(Aes item, CoordConv coord, Canvas canvas) {
    // TODO: implement paintItem
  }
}

class HistogramShape extends IntervalShape {
  @override
  bool equalTo(Object other) =>
    other is HistogramShape;

  @override
  void paintGroup(List<Aes> group, CoordConv coord, Canvas canvas) {
    // TODO: implement paintGroup
  }

  @override
  void paintItem(Aes item, CoordConv coord, Canvas canvas) {
    // TODO: implement paintItem
  }
}

class PyramidShape extends IntervalShape {
  @override
  bool equalTo(Object other) =>
    other is PyramidShape;

  @override
  void paintGroup(List<Aes> group, CoordConv coord, Canvas canvas) {
    // TODO: implement paintGroup
  }

  @override
  void paintItem(Aes item, CoordConv coord, Canvas canvas) {
    // TODO: implement paintItem
  }
}
