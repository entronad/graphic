import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/reserveds.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/scale/linear.dart';
import 'package:graphic/src/scale/ordinal.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/scale/time.dart';

import 'transform/filter.dart';
import 'transform/map.dart';
import 'transform/proportion.dart';
import 'transform/sort.dart';

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
  }) : assert(
    accessor is Accessor<D, String> ||
    accessor is Accessor<D, num> ||
    accessor is Accessor<D, DateTime>
  );

  /// Indicates how to get the variable value from a datum.
  Accessor<D, V> accessor;

  /// Scale specification of this variable.
  /// 
  /// If null, a default scale is inferred from type [V], [OrdinalScale] for [String],
  /// [LinearScale] for [num], and [TimeScale] for [DateTime]
  Scale<V, num>? scale;

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
/// value: List<Tuple>
/// Tuple tuples
class VariableOp<D> extends Operator<List<Tuple>> {
  VariableOp(Map<String, dynamic> params) : super(params);

  @override
  List<Tuple> evaluate() {
    final accessors = params['accessors'] as Map<String, Accessor<D, dynamic>>;
    final data = params['data'] as List<D>;

    final rst = <Tuple>[];
    for (var datum in data) {
      final tuple = Tuple();
      for (var name in accessors.keys) {
        tuple[name] = accessors[name]!(datum);
      }
      rst.add(tuple);
    }

    return rst;
  }
}

void parseVariable<D>(
  Chart<D> spec,
  View<D> view,
  Scope<D> scope,
) {
  final accessors = <String, Accessor<D, dynamic>>{};
  final variableSpecs = spec.variables;
  for (var field in variableSpecs.keys) {
    final accessor = variableSpecs[field]!.accessor;
    final scaleSpec = variableSpecs[field]!.scale;
    accessors[field] = accessor;
    if (accessor is Accessor<D, String>) {
      scope.scaleSpecs[field] = scaleSpec ?? OrdinalScale();
    } else if (accessor is Accessor<D, num>) {
      scope.scaleSpecs[field] = scaleSpec ?? LinearScale();
    } else if (accessor is Accessor<D, DateTime>) {
      scope.scaleSpecs[field] = scaleSpec ?? TimeScale();
    } else {
      throw ArgumentError('Variable value must be String, num, or DataTime');
    }
  }

  Operator<List<Tuple>> tuples = view.add(VariableOp<D>({
    'accessors': accessors,
    'data': scope.data,
  }));

  final transformSpecs = spec.transforms;
  if (transformSpecs != null) {
    for (var transformSpec in transformSpecs) {
      if (transformSpec is Filter) {
        tuples = view.add(FilterOp({
          'tuples': tuples,
          'test': transformSpec.test,
        }));
      } else if (transformSpec is MapTrans) {
        tuples = view.add(MapOp({
          'tuples': tuples,
          'mapper': transformSpec.mapper,
        }));
      } else if (transformSpec is Proportion) {
        final as = transformSpec.as;
        assert(scope.scaleSpecs[as] == null);
        scope.scaleSpecs[as] = transformSpec.scale ?? LinearScale(min: 0, max: 1);

        tuples = view.add(ProportionOp({
          'tuples': tuples,
          'variable': transformSpec.variable,
          'groupBy': transformSpec.groupBy,
          'as': as,
        }));
      } else if (transformSpec is Sort) {
        tuples = view.add(SortOp({
          'tuples': tuples,
          'compare': transformSpec.compare,
        }));
      } else {
        throw UnimplementedError('No such transform $transformSpec.');
      }
    }
  }

  scope.tuples = tuples;

  assert(Reserveds.legalIdentifiers(scope.scaleSpecs.keys));
}
