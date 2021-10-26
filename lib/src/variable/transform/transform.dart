import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import '../variable.dart';

/// The specification of a variable transform.
/// 
/// A transform applies a statistical transformation on the original value tuples
/// defined in [Variable]s. It may modify tuple field values, create new fields,
/// or change the length of the tuple list.
/// 
/// See also:
/// 
/// - [Variable], to define the variables which transforms are applied.
/// - [Tuple], the original value tuple.
abstract class VariableTransform {
  @override
  bool operator ==(Object other) =>
    other is VariableTransform;
}

abstract class TransformOp extends Operator<List<Tuple>> {
  TransformOp(Map<String, dynamic> params) : super(params);
}
