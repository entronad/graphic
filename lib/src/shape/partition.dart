import 'dart:ui';

import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';

import 'shape.dart';

/// The shape for the partition element.
/// 
/// See also:
/// 
/// - [PartitionElement], which this shape is for.
abstract class PartitionShape extends Shape {
  @override
  double get defaultSize =>
    throw UnimplementedError('Partition dose not involve size.');
  
  @override
  List<Figure> renderItem(
    Aes item,
    CoordConv coord,
    Offset origin,
  ) => throw UnimplementedError('Partition only paints group.');
}
