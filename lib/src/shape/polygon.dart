import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';

import 'shape.dart';
import 'partition.dart';

abstract class PolygonShape extends PartitionShape {
  
}

class HeatmapShape extends PolygonShape {
  @override
  bool equalTo(Object other) =>
    other is HeatmapShape;

  @override
  void paintGroup(List<Aes> group, CoordConv coord, Canvas canvas) {
    // TODO: implement paintGroup
  }

  @override
  void paintItem(Aes item, CoordConv coord, Canvas canvas) {
    // TODO: implement paintItem
  }
}

class VoronoiShape extends PolygonShape {
  @override
  bool equalTo(Object other) =>
    other is VoronoiShape;

  @override
  void paintGroup(List<Aes> group, CoordConv coord, Canvas canvas) {
    // TODO: implement paintGroup
  }

  @override
  void paintItem(Aes item, CoordConv coord, Canvas canvas) {
    // TODO: implement paintItem
  }
}
