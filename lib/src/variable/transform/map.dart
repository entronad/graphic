import 'package:graphic/src/dataflow/tuple.dart';

import 'transform.dart';

/// The transform to map each tuple to a new tuple.
/// 
/// See also:
/// - [Tuple], the original value tuple.
class MapTrans extends VariableTransform {
  /// Creates a map transform.
  MapTrans({
    required this.mapper,
  });

  /// Indicates how to get the new tuple from each tuple.
  Tuple Function(Tuple) mapper;

  @override
  bool operator ==(Object other) =>
    other is MapTrans &&
    super == other;
    // mapper is Function.
}

class MapOp extends TransformOp {
  MapOp(Map<String, dynamic> params) : super(params);

  @override
  List<Tuple> evaluate() {
    final tuples = params['tuples'] as List<Tuple>;
    final mapper = params['mapper'] as Tuple Function(Tuple);

    return tuples.map((tuple) => mapper(tuple)).toList();
  }
}
