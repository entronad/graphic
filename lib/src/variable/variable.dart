import 'package:graphic/src/dataflow/operator/transformer.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/scale.dart';

typedef Accessor<D, V> = V Function(D);

/// [D]: Type of source data items.
/// [V]: Type of variable value.
class Variable<D, V> {
  Variable({
    required this.accessor,
    this.scale,
    this.title,
  });

  final Accessor<D, V>? accessor;

  /// If not provided, a default scale is infered from the type of [V].
  ///     [OrdinalScale] for [String]
  ///     [LinearScale] for [num]
  ///     [TimeScale] for [DateTime]
  final Scale<V, dynamic>? scale;

  /// To represent this variable in tooltip/legend/label/tag.
  /// Default to use the name of the variable.
  final String? title;

  @override
  bool operator ==(Object other) =>
    other is Variable<D, V> &&
    // accessor: Function
    scale == other.scale &&
    title == other.title;
}

/// Variable is the start of pulse, it outpus pulse.
/// 
/// value: List<D>
/// Souce data, set in constructor or updated by data source.
/// 
/// params:
/// - accessors: Map<String, accessor>
/// - preTuples: List<Tuples> <- Collect, prior original value tuples form collect after transforms.
/// 
/// pulse int:
/// - in: Empty pulse(dataflow._pulse) inited in dataflow.evaluate().
/// - out: original value tuples.
class VariableOp<D> extends Transformer<List<D>> {
  VariableOp(
    Map<String, dynamic> params,
    List<D> value,
  ) : super(params, value);

  @override
  Pulse? transform(Pulse pulse) {
    final accessors = params['accessors'] as Map<String, Accessor>;
    final preTuples = params['preTuples'] as List<Tuple>;
    final value = this.value!;

    // On data event(both init and update), remove all tuples and add all new tuples.
    // pulse.source will be added in Collect.
    // pulse is clean and useless in original value branch, don't need to fork.
    pulse.rem = [...preTuples];
    for (var datum in value) {
      final tuple = Tuple();
      for (var name in accessors.keys) {
        tuple[name] = accessors[name]!(datum);
      }
      pulse.add.add(tuple);
    }

    return pulse;
  }
}
