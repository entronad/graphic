import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';

abstract class VariableTransform {
  @override
  bool operator ==(Object other) =>
    other is VariableTransform;
}

abstract class TransformOp extends Operator<List<Original>> {
  TransformOp(Map<String, dynamic> params) : super(params);
}
