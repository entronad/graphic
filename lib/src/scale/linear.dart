import 'dart:math' as math;

import 'package:graphic/src/dataflow/tuple.dart';

import 'continuous.dart';

class LinearScale extends ContinuousScale<num> {
  LinearScale({
    num? min,
    num? max,

    String Function(num)? formatter,
  }) : super(
    min: min,
    max: max,
    formatter: formatter,
  );
}

class LinearScaleConv extends ContinuousScaleConv<num> {
  LinearScaleConv(
    num? min,
    num? max,
  ) : super(min, max);

  @override
  double convert(num input) =>
    (input - min!) / (max! - min!);

  @override
  num invert(double output) =>
    min! + output * (max! - min!);

  @override
  void complete(List<Tuple> tuples, String field) {
    if (min == null || max == null) {
      var minTmp = tuples.first[field] as num;
      var maxTmp = minTmp;
      for (var tuple in tuples) {
        final value = tuple[field] as num;
        minTmp = math.min(minTmp, value);
        maxTmp = math.max(maxTmp, value);
      }
      min = min ?? minTmp;
      max = max ?? maxTmp;
    }
  }
}
