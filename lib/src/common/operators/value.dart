import 'package:graphic/src/dataflow/operator.dart';

/// Value operator are always source nodes of the dataflow and can never be touched.
/// It can keep value and be updated by event stream.
class Value<V> extends Operator<V> {
  Value([V? value]) : super(null, value);

  @override
  V evaluate() => throw UnimplementedError('Value operator cannot be touched');
}
