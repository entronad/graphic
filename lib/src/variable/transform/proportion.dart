import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/scale.dart';

import 'transform.dart';

class Proportion extends Transform {
  Proportion({
    required this.variable,
    this.groupBy,
    required this.as,
    this.scale,
  });

  final String variable;

  final String? groupBy;

  final String as;

  final Scale? scale;

  @override
  bool operator ==(Object other) =>
    other is Proportion &&
    super == other &&
    variable == other.variable &&
    groupBy == other.groupBy &&
    as == other.as &&
    scale == other.scale;
}

class ProportionOp extends TransformOp {
  ProportionOp(Map<String, dynamic> params) : super(params);

  @override
  List<Original> evaluate() {
    final originals = params['originals'] as List<Original>;
    final variable = params['variable'] as String;
    final groupBy = params['groupBy'] as String?;
    final as = params['as'] as String;

    if (groupBy == null) {
      num sum = 0;
      for (var original in originals) {
        sum += original[variable];
      }
      for (var original in originals) {
        original[as] = original[variable] / sum;
      }
    } else {
      final sums = <String, num>{};
      for (var original in originals) {
        final cat = original[groupBy];
        var sum = sums[cat];
        sum = sum == null
          ? original[variable]
          : sum + original[variable];
        sums[cat] = sum!;
      }
      for (var original in originals) {
        final cat = original[groupBy];
        var sum = sums[cat];
        original[as] = original[variable] / sum;
      }
    }

    return originals;
  }
}
