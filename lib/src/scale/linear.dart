import 'dart:math' as math;

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/util/nice_numbers.dart';
import 'package:graphic/src/scale/util/nice_range.dart';

import 'continuous.dart';

/// The specification of a linear scale.
///
/// It converts [num] to [double]s normalized to `[0, 1]` linearly.
class LinearScale extends ContinuousScale<num> {
  /// Creates a linear scale.
  LinearScale({
    num? min,
    num? max,
    double? marginMin,
    double? marginMax,
    String? title,
    String? Function(num)? formatter,
    List<num>? ticks,
    int? tickCount,
    bool? niceRange,
  }) : super(
          min: min,
          max: max,
          marginMin: marginMin,
          marginMax: marginMax,
          title: title,
          formatter: formatter,
          ticks: ticks,
          tickCount: tickCount,
          niceRange: niceRange,
        );

  @override
  bool operator ==(Object other) => other is LinearScale && super == other;
}

/// The linear scale converter.
class LinearScaleConv extends ContinuousScaleConv<num> {
  LinearScaleConv(
    LinearScale spec,
    List<Tuple> tuples,
    String variable,
  ) {
    if (spec.min != null && spec.max != null) {
      min = spec.min;
      max = spec.max;
    } else {
      // Don't use the first one in case it is NaN.
      num minTmp = double.infinity;
      num maxTmp = double.negativeInfinity;
      for (var tuple in tuples) {
        final value = tuple[variable] as num;
        if (!value.isNaN) {
          minTmp = math.min(minTmp, value);
          maxTmp = math.max(maxTmp, value);
        }
      }

      // If all data are the same, the range is 10, to get a nice margin 1 and avoid
      // 0 problem.
      final range = maxTmp == minTmp ? 10 : maxTmp - minTmp;
      final marginMin = range * (spec.marginMin ?? 0.1);
      final marginMax = range * (spec.marginMax ?? 0.1);
      min = spec.min ?? minTmp - marginMin;
      max = spec.max ?? maxTmp + marginMax;
    }

    final tickCount = spec.tickCount ?? 5;

    if (spec.niceRange == true) {
      final niceRange = linearNiceRange(min!, max!, tickCount);
      min = niceRange.first;
      max = niceRange.last;
    }

    if (spec.ticks != null) {
      ticks = spec.ticks!;
    } else {
      ticks = linearNiceNumbers(min!, max!, tickCount);
    }

    title = spec.title ?? variable;
    formatter = spec.formatter ?? defaultFormatter;
  }

  @override
  double convert(num input) => (input - min!) / (max! - min!);

  @override
  num invert(double output) => min! + output * (max! - min!);

  @override
  num get zero => 0;

  @override
  String defaultFormatter(num value) => value.toString();

  @override
  bool operator ==(Object other) => other is LinearScaleConv && super == other;
}
