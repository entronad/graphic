import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/operator/op_params.dart';
import 'package:graphic/src/dataflow/operator/transformer.dart';
import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'ordinal.dart';
import 'linear.dart';
import 'time.dart';

/// [V]: Type of input variable value.
/// [SV]: Type of scaled value result,
///     [int] for discrete and
///     [double] for continuous.
abstract class Scale<V, SV extends num> {
  Scale({
    this.formatter,
  });

  final String Function(V)? formatter;

  @override
  bool operator ==(Object other) =>
    other is Scale<V, SV>;
    // formatter: Function
}

abstract class ScaleConv<V, SV extends num> extends Converter<V, SV> {
  void complete(List<Tuple> tuples, String field);
}

Map<String, ScaleConv> _createConvs(OpParams params, Pulse pulse) {
  final specs = params['specs'] as Map<String, Scale>;
  final rst = <String, ScaleConv>{};
  for (var name in specs.keys) {
    if (specs[name] is OrdinalScale) {
      final spec = specs[name] as OrdinalScale;
      rst[name] = OrdinalScaleConv(spec.values)
        ..complete(pulse.source!, name);
    } else if (specs[name] is LinearScale) {
      final spec = specs[name] as LinearScale;
      rst[name] = LinearScaleConv(spec.min, spec.max)
        ..complete(pulse.source!, name);
    } else if (specs[name] is TimeScale) {
      final spec = specs[name] as TimeScale;
      rst[name] = TimeScaleConv(spec.min, spec.max)
        ..complete(pulse.source!, name);
    }
  }
  return rst;
}

/// params:
/// - specs: Map<String, Scale>, Scale specs of all variables.
/// 
/// pulse:
/// Original value pulse before scale,
/// Only has rem to clear pre tuples and add to add new tuples.
/// 
/// value: Map<String, ScaleConv>
/// Scale converter of all variables.
class ScaleConvOp extends Updater<Map<String, ScaleConv>> {
  ScaleConvOp(
    Map<String, dynamic> params,
  ) : super({}, params, _createConvs);  // must be inited by a pulse.
}

/// params:
/// Map<String, ScaleConv> convs: Scale convertors.
/// 
/// pulse:
/// - in: Original value pulse before scale,
///     Only has rem to clear pre tuples and add to add new tuples.
/// - out: Scaled vaue tuples
/// 
/// value: Map<tuple, tuple>
/// Map form scaled value tuple to original value tuple.
/// scaled values tuples will be stored at the next collect.
class ScaleOp extends Transformer<Map<Tuple, Tuple>> {
  ScaleOp(Map<String, dynamic> params) : super({}, params);

  @override
  Pulse? transform(OpParams params, Pulse pulse) {
    final convs = params['convs'] as Map<String, ScaleConv>;

    // For pulse shifting operators, should fork a totally new pulse,
    //     and source will be added in the next collect.
    final rst = pulse.fork(PulseFlags.none);

    pulse.visit(PulseFlags.rem, (tuple) {
      final scaled = value.entries.firstWhere(
        (entry) => entry.value == tuple,
      ).key;
      value.remove(scaled);
      rst.rem.add(scaled);
    });

    pulse.visit(PulseFlags.add, (tuple) {
      final scaled = Tuple();
      for (var field in convs.keys) {
        scaled[field] = convs[field]!.convert(tuple[field]);
      }
      value[scaled] = tuple;
      rst.add.add(scaled);
    });

    pulse.visit(PulseFlags.mod, (tuple) {
      final scaled = value.entries.firstWhere(
        (entry) => entry.value == tuple,
      ).key;
      scaled.clear();
      for (var field in convs.keys) {
        scaled[field] = convs[field]!.convert(tuple[field]);
      }
      rst.mod.add(scaled);
    });
    // TODO: modField?

    return rst;
  }
}
