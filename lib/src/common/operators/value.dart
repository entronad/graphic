import 'package:graphic/src/dataflow/operator.dart';

/// The operator to hold a value.
///
/// Value operators are source nodes of the dataflow. The cannot be touched and
/// only be updated by streams.
class Value<V> extends Operator<V> {
  Value([V? value]) : super(null, value);

  @override
  bool get runInit => false;

  @override
  V evaluate() => throw UnimplementedError('Value operator cannot be touched');
}
