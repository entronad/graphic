import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/linear.dart';
import 'package:graphic/src/scale/ordinal.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/scale/time.dart';

/// Signature for [Variable.accessor].
///
/// See also:
///
/// - [Variable], which uses the signature to define an accessor.
typedef Accessor<D, V> = V Function(D);

/// The specification of a variable.
///
/// Instead of raw [Chart.data], the chart reorgnize datum to "original value tuple"
/// (See details in [Tuple]) for internal usage. The variable defines how to create
/// a field in original value tuple form input datum, and the scale specification
/// of the field.
///
/// The generic [D] is the type of datum in [Chart.data] list, and [V] is the type
/// of field value. [V] can only be [String], [num] or [DateTime].
///
/// See also:
///
/// - [Tuple], the original value tuple.
class Variable<D, V> {
  /// Creates a variable specification.
  Variable({
    required this.accessor,
    this.scale,
  }) : assert(accessor is Accessor<D, String> ||
            accessor is Accessor<D, num> ||
            accessor is Accessor<D, DateTime>);

  /// Indicates how to get the variable value from a datum.
  Accessor<D, V> accessor;

  /// Scale specification of this variable.
  ///
  /// If null, a default scale is inferred from type [V], [OrdinalScale] for [String],
  /// [LinearScale] for [num], and [TimeScale] for [DateTime]
  Scale<V, num>? scale;

  @override
  bool operator ==(Object other) =>
      other is Variable<D, V> && scale == other.scale;
}

/// The operator to create original value tuples from input data.
class VariableOp<D> extends Operator<List<Tuple>> {
  VariableOp(Map<String, dynamic> params) : super(params);

  @override
  List<Tuple> evaluate() {
    final accessors = params['accessors'] as Map<String, Accessor<D, dynamic>>;
    final data = params['data'] as List<D>;

    final rst = <Tuple>[];
    for (var datum in data) {
      final Map<String, dynamic> tuple = {};
      for (var name in accessors.keys) {
        tuple[name] = accessors[name]!(datum);
      }
      rst.add(tuple);
    }

    return rst;
  }
}
