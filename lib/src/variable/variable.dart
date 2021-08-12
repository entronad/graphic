import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/scale.dart';

typedef Accessor<D, V> = V Function(D);

/// [D]: Type of source data items.
/// [V]: Type of variable value.
class Variable<D, V> {
  Variable({
    required this.accessor,
    this.scale,
  });

  final Accessor<D, V>? accessor;

  /// Also act like avatar of a variable, keeps it's meta information.
  /// If not provided, a default scale is infered from the type of [V].
  ///     [OrdinalScale] for [String]
  ///     [LinearScale] for [num]
  ///     [TimeScale] for [DateTime]
  final Scale<V, dynamic>? scale;

  @override
  bool operator ==(Object other) =>
    other is Variable<D, V> &&
    // accessor: Function
    scale == other.scale;
}

/// params:
/// - accessors: Map<String, accessor>
/// - data: List<D>
/// 
/// value: List<Original>
/// Original tuples
class VariableOp<D> extends Operator<List<Original>> {
  VariableOp(Map<String, dynamic> params) : super(params);

  @override
  List<Original> evaluate() {
    final accessors = params['accessors'] as Map<String, Accessor>;
    final data = params['data'] as List<D>;

    final rst = <Original>[];
    for (var datum in data) {
      final tuple = Original();
      for (var name in accessors.keys) {
        tuple[name] = accessors[name]!(datum);
      }
      rst.add(tuple);
    }

    return rst;
  }
}
