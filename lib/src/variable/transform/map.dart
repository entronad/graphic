import 'package:graphic/src/dataflow/tuple.dart';

import 'transform.dart';

class MapTrans extends Transform {
  MapTrans({
    required this.mapper,
  });

  final Original Function(Original) mapper;

  @override
  bool operator ==(Object other) =>
    other is MapTrans &&
    super == other;
    // mapper is Function.
}

class MapOp extends TransformOp {
  MapOp(Map<String, dynamic> params) : super(params);

  @override
  List<Original> evaluate() {
    final originals = params['originals'] as List<Original>;
    final mapper = params['mapper'] as Original Function(Original);

    return originals.map((original) => mapper(original)).toList();
  }
}
