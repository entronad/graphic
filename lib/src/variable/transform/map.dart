import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/scale.dart';

import 'transform.dart';

class MapTrans extends Transform {
  MapTrans({
    required this.variable,
    required this.as,
    required this.mapper,
    this.scale,
  });

  final String variable;

  final String as;

  final dynamic Function(dynamic) mapper;

  final Scale? scale;

  @override
  bool operator ==(Object other) =>
    other is MapTrans &&
    super == other &&
    variable == other.variable &&
    as == other.as &&
    // mapper is Function.
    scale == other.scale;
}

class MapOp extends TransformOp {
  MapOp(Map<String, dynamic> params) : super(params);

  @override
  List<Original> evaluate() {
    final tuples = params['tuples'] as List<Original>;
    final variable = params['variable'] as String;
    final as = params['as'] as String;
    final mapper = params['mapper'] as dynamic Function(dynamic);

    return tuples..forEach((tuple) {
      tuple[as] = mapper(tuple[variable]);
    });
  }
}
