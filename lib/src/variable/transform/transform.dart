import 'package:graphic/src/dataflow/operator/transformer.dart';

abstract class Transform {
  @override
  bool operator ==(Object other) =>
    other is Transform;
}

abstract class TransformOp extends Transformer {
  TransformOp(Map<String, dynamic> params) : super(null, params);
}
