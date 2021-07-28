import 'shape.dart';

abstract class PartitionShape extends Shape {
  @override
  double get defaultSize =>
    throw UnimplementedError('Partition shape dose not involve size.');
}
