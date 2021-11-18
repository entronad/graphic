import 'package:graphic/src/dataflow/tuple.dart';

import 'transform.dart';

/// The transform to get tuples that satisfy a certain predicate.
///
/// This may reduce the length of original value tuples.
///
/// See also:
/// - [Tuple], the original value tuple.
class Filter extends VariableTransform {
  /// Creates a filter transform.
  Filter({
    required this.predicate,
  });

  /// The testing predicate.
  bool Function(Tuple) predicate;

  @override
  bool operator ==(Object other) => other is Filter && super == other;
}

/// The filter transform operator.
class FilterOp extends TransformOp {
  FilterOp(Map<String, dynamic> params) : super(params);

  @override
  List<Tuple> evaluate() {
    final tuples = params['tuples'] as List<Tuple>;
    final predicate = params['predicate'] as bool Function(Tuple);

    return tuples.where((tuple) => predicate(tuple)).toList();
  }
}
