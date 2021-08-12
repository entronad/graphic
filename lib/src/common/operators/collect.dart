import 'package:graphic/src/dataflow/operator.dart';

/// Collect and provide tuples.
class Collect<T> extends Operator<List<T>> {
  Collect(Operator<List<T>> source)
    : super({'souce' : source});

  @override
  List<T> evaluate() =>
    value = params['souce'] as List<T>;
}
