import 'dart:ui';

import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/coord/coord.dart';

import 'shape.dart';

abstract class PartitionShape extends Shape {
  @override
  double get defaultSize =>
    throw UnimplementedError('Partition dose not involve size.');
  
  @override
  void paintItem(
    Aes item,
    CoordConv coord,
    Canvas canvas,
  ) => throw UnimplementedError('Partition only paints group.');
}
