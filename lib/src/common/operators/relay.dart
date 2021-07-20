import 'package:graphic/src/dataflow/operator/transformer.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';


/// To create new type pulse form another type's change info.
/// The new pulse will have no source. If you need one, append a collect.
/// The value of Relay is often named relay as a param. And the prefix is output type.
/// 
/// params:
/// - fieldsMapper: Set<String> Function(Set<String>), How to get output modFields from input modFields.
///     Commonly used:
///     (input) => {}.addAll(input): One-to-one unchanged.
///     (_) => allOutuptFields
/// 
/// value: Map<Tuple, Tuple>
/// Lookup table between input and out put tuples: {input: output}
/// 
/// pulse:
/// Input and output are of different types but same change info.
class Relay extends Transformer<Map<Tuple, Tuple>> {
  Relay(
    Map<String, dynamic> params,
  ) : super(params, {});

  @override
  Pulse? transform(Pulse pulse) {
    final fieldsMapper = params['fieldsMapper'] as Set<String> Function(Set<String>);
    final value = this.value!;

    final rst = pulse.fork(PulseFlags.none);

    pulse.visit(PulseFlags.rem, (tuple) {
      final outTuple = value[tuple]!;
      value.remove(outTuple);
      rst.rem.add(outTuple);
    });

    pulse.visit(PulseFlags.add, (tuple) {
      final outTuple = Tuple();
      value[outTuple] = tuple;
      rst.add.add(outTuple);
    });

    rst.modFields = fieldsMapper(pulse.modFields);
    pulse.visit(PulseFlags.mod, (tuple) {
      final outTuple = value[tuple]!;
      rst.mod.add(outTuple);
    });

    return rst;
  }
}
