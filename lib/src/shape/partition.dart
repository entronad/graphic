import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'shape.dart';

abstract class PartitionShape extends Shape {
  @override
  double get defaultSize =>
    throw UnimplementedError('Partition dose not involve size.');
  
  @override
  void paintItem(
    Aes item,
    CoordConv coord,
    Offset origin,
    Canvas canvas,
  ) => throw UnimplementedError('Partition only paints group.');
}
