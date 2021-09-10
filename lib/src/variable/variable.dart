import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/scale/linear.dart';
import 'package:graphic/src/scale/ordinal.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/scale/time.dart';

import 'transform/filter.dart';
import 'transform/map.dart';
import 'transform/proportion.dart';
import 'transform/sort.dart';

typedef Accessor<D, V> = V Function(D);

/// [D]: Type of source data items.
/// [V]: Type of variable value.
class Variable<D, V> {
  Variable({
    required this.accessor,
    this.scale,
  });

  final Accessor<D, V> accessor;

  /// Also act like avatar of a variable, keeps it's meta information.
  /// If not provided, a default scale is infered from the type of [V].
  ///     [OrdinalScale] for [String]
  ///     [LinearScale] for [num]
  ///     [TimeScale] for [DateTime]
  final Scale<V, num>? scale;

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
    final accessors = params['accessors'] as Map<String, Accessor<D, dynamic>>;
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

void parseVariable<D>(
  Spec<D> spec,
  View<D> view,
  Scope<D> scope,
) {
  final accessors = <String, Accessor<D, dynamic>>{};
  final variableSpecs = spec.data.variables;
  for (var field in variableSpecs.keys) {
    final variableSpec = variableSpecs[field]!;
    accessors[field] = variableSpec.accessor;
    if (variableSpec is Variable<D, String>) {
      scope.scaleSpecs[field] = variableSpec.scale ?? OrdinalScale();
    } else if (variableSpec is Variable<D, num>) {
      scope.scaleSpecs[field] = variableSpec.scale ?? LinearScale();
    } else if (variableSpec is Variable<D, DateTime>) {
      scope.scaleSpecs[field] = variableSpec.scale ?? TimeScale();
    } else {
      throw ArgumentError('Variable value must be String, num, or DataTime');
    }
  }

  Operator<List<Original>> originals = view.add(VariableOp<D>({
    'accessors': accessors,
    'data': scope.data,
  }));

  final transformSpecs = spec.data.transforms;
  if (transformSpecs != null) {
    for (var transformSpec in transformSpecs) {
      if (transformSpec is Filter) {
        originals = view.add(FilterOp({
          'originals': originals,
          'filter': transformSpec.filter,
        }));
      } else if (transformSpec is MapTrans) {
        originals = view.add(MapOp({
          'originals': originals,
          'mapper': transformSpec.mapper,
        }));
      } else if (transformSpec is Proportion) {
        final as = transformSpec.as;
        assert(scope.scaleSpecs[as] == null);
        scope.scaleSpecs[as] = transformSpec.scale ?? LinearScale();

        originals = view.add(ProportionOp({
          'originals': originals,
          'varibale': transformSpec.variable,
          'groupBy': transformSpec.groupBy,
          'as': transformSpec.as,
        }));
      } else if (transformSpec is Sort) {
        originals = view.add(SortOp({
          'originals': originals,
          'compare': transformSpec.compare,
        }));
      } else {
        throw UnimplementedError('No such transform.');
      }
    }
  }

  scope.originals = originals;
}
