import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/element.dart';
import 'package:graphic/src/scale/scale.dart';

import 'transform.dart';

/// The transform to calculate proportion of a certain field value of a tuple in
/// all (or in a certain group) tuples.
///
/// This will create a new variable for results.
///
/// See also:
/// - [Tuple], the original value tuple.
class Proportion extends VariableTransform {
  /// Creates a proportion transform.
  Proportion({
    required this.variable,
    this.nest,
    required this.as,
    this.scale,
  });

  /// Which variable to calculate the proportion.
  String variable;

  /// The algebracal expression to nest the proportion.
  ///
  /// If set, the tuples will temporarily grouped by it, and the denominator of
  /// proportion will be sum of a single group. If null, the denominator will be
  /// sum of all.
  ///
  /// See details about nesting rules in [Varset]. Note this property is only the
  /// right oprand of nesting.
  Varset? nest;

  /// The name identifier of result variable.
  String as;

  /// The scale of result variable.
  ///
  /// If null, a default `LinearScale(min: 0, max: 1)` is set.
  Scale? scale;

  @override
  bool operator ==(Object other) =>
      other is Proportion &&
      super == other &&
      variable == other.variable &&
      nest == other.nest &&
      as == other.as &&
      scale == other.scale;
}

/// The proportion transform operator.
///
/// The evaluation of nesting is like the [GroupOp].
class ProportionOp extends TransformOp {
  ProportionOp(Map<String, dynamic> params) : super(params);

  @override
  List<Tuple> evaluate() {
    final tuples = params['tuples'] as List<Tuple>;
    final variable = params['variable'] as String;
    final nesters = params['nesters'] as List<AlgForm>;
    final as = params['as'] as String;

    if (nesters.isEmpty) {
      num sum = 0;
      for (var tuple in tuples) {
        sum += tuple[variable];
      }
      for (var tuple in tuples) {
        tuple[as] = tuple[variable] / sum;
      }
    } else {
      final nesterVariables = <String>[];
      for (var nesterForm in nesters) {
        for (var nesterTerm in nesterForm) {
          nesterVariables.addAll(nesterTerm);
        }
      }

      final nesterValuesMap = <String, Set>{};
      for (var nester in nesterVariables) {
        nesterValuesMap[nester] = {};
        for (var tuple in tuples) {
          nesterValuesMap[nester]!.add(tuple[nester]);
        }
      }

      var groups = [tuples];

      for (var nester in nesterVariables) {
        final tmpRst = <List<Tuple>>[];
        for (var group in groups) {
          final nesterValues = nesterValuesMap[nester]!;
          final tmpGroup = <dynamic, List<Tuple>>{};
          for (var nesterValue in nesterValues) {
            tmpGroup[nesterValue] = <Tuple>[];
          }
          for (var tuple in group) {
            tmpGroup[tuple[nester]]!.add(tuple);
          }
          tmpRst.addAll(tmpGroup.values.where((g) => g.isNotEmpty));
        }
        groups = tmpRst;
      }

      for (var group in groups) {
        num sum = 0;
        for (var tuple in group) {
          sum += tuple[variable];
        }
        for (var tuple in group) {
          tuple[as] = tuple[variable] / sum;
        }
      }
    }

    return tuples;
  }
}
