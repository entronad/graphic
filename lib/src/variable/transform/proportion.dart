import 'package:graphic/src/dataflow/tuple.dart';
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
    this.groupBy,
    required this.as,
    this.scale,
  });

  /// Which variable to calculate the proportion.
  String variable;

  /// Which variable to group tuples by.
  ///
  /// If set, the denominator of proportion will be sum of a group, and if null
  /// will be sum of all.
  ///
  /// The variable should be discrete.
  String? groupBy;

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
      groupBy == other.groupBy &&
      as == other.as &&
      scale == other.scale;
}

/// The proportion transform operator.
class ProportionOp extends TransformOp {
  ProportionOp(Map<String, dynamic> params) : super(params);

  @override
  List<Tuple> evaluate() {
    final tuples = params['tuples'] as List<Tuple>;
    final variable = params['variable'] as String;
    final groupBy = params['groupBy'] as String?;
    final as = params['as'] as String;

    if (groupBy == null) {
      num sum = 0;
      for (var tuple in tuples) {
        sum += tuple[variable];
      }
      for (var tuple in tuples) {
        tuple[as] = tuple[variable] / sum;
      }
    } else {
      final sums = <String, num>{};
      for (var tuple in tuples) {
        final cat = tuple[groupBy];
        var sum = sums[cat];
        sum = sum == null ? tuple[variable] : sum + tuple[variable];
        sums[cat] = sum!;
      }
      for (var tuple in tuples) {
        final cat = tuple[groupBy];
        var sum = sums[cat];
        tuple[as] = tuple[variable] / sum;
      }
    }

    return tuples;
  }
}
