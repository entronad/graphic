import 'package:graphic/src/dataflow/pulse/pulse.dart';
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

/// params:
/// - variable: String
/// - as: String
/// - mapper: dynamic Function(dynamic)
/// - preTuples: List<Tuples> <- Collect, prior original value tuples form collect after transforms.
/// 
/// pulse:
/// original value tuples
/// 
/// TODO: String scale
class MapOp extends TransformOp {
  MapOp(Map<String, dynamic> params) : super(params);

  @override
  Pulse? transform(Pulse pulse) {
    final variable = params['variable'] as String;
    final as = params['as'] as String;
    final mapper = params['mapper'] as dynamic Function(dynamic);

    // Only handles add.
    pulse.visit(PulseFlags.add, (tuple) {
      tuple[as] = mapper(tuple[variable]);
    });

    return pulse;
  }
}
