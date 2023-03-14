import 'package:graphic/src/mark/partition.dart';

import 'shape.dart';

/// The shape for the partition mark.
///
/// See also:
///
/// - [PartitionMark], which this shape is for.
abstract class PartitionShape extends Shape {
  @override
  double get defaultSize =>
      throw UnimplementedError('Partition dose not involve size.');
}
