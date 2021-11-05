import 'package:graphic/src/dataflow/tuple.dart';

import 'transform.dart';

/// The transform to sort the tuple list.
///
/// See also:
/// - [Tuple], the original value tuple.
class Sort extends VariableTransform {
  /// Creates sort transform.
  Sort({
    required this.compare,
  });

  /// The comparison function for sorting.
  Comparator<Tuple> compare;

  @override
  bool operator ==(Object other) => other is Sort && super == other;
}

/// The sort transform operator.
class SortOp extends TransformOp {
  SortOp(Map<String, dynamic> params) : super(params);

  @override
  List<Tuple> evaluate() {
    final tuples = params['tuples'] as List<Tuple>;
    final compare = params['compare'] as Comparator<Tuple>;

    return tuples..sort(compare);
  }
}
