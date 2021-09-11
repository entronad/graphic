import 'dart:math' as math;

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/auto_ticks/num.dart';

import 'continuous.dart';

class LinearScale extends ContinuousScale<num> {
  LinearScale({
    this.tickInterval,
    this.nice,

    num? min,
    num? max,

    String? title,
    String Function(num)? formatter,
    List<num>? ticks,
    int? tickCount,
    int? maxTickCount,
  }) : super(
    min: min,
    max: max,
    title: title,
    formatter: formatter,
    ticks: ticks,
    tickCount: tickCount,
    maxTickCount: maxTickCount,
  );

  final num? tickInterval;

  final bool? nice;

  @override
  bool operator ==(Object other) =>
    other is LinearScale &&
    super == other &&
    tickInterval == other.tickInterval &&
    nice == other.nice;
}

class LinearScaleConv extends ContinuousScaleConv<num> {
  LinearScaleConv(
    LinearScale spec,
    List<Original> tuples,
    String variable,
  ) {
    // min, max
    if (spec.min != null && spec.max != null) {
      min = spec.min;
      max = spec.max;
    } else {
      var minTmp = tuples.first[variable] as num;
      var maxTmp = minTmp;
      for (var tuple in tuples) {
        final value = tuple[variable] as num;
        minTmp = math.min(minTmp, value);
        maxTmp = math.max(maxTmp, value);
      }
      min = min ?? minTmp;
      max = max ?? maxTmp;
    }

    // ticks
    if (spec.ticks != null) {
      ticks = spec.ticks!;
      final firstTick = ticks.first;
      final lastTick = ticks.last;
      if (min! > firstTick) {
        min = firstTick;
      }
      if (max! < lastTick) {
        max = lastTick;
      }
    } else {
      List<num> calcTicks;
      if (spec.tickCount != 0) {
        calcTicks = numAutoTicks(
          minValue: min!,
          maxValue: max!,
          minCount: spec.tickCount,
          maxCount: spec.tickCount,
          interval: spec.tickInterval,
        );
      } else {
        calcTicks = numAutoTicks(
          minValue: min!,
          maxValue: max!,
          minCount: 1,
          maxCount: spec.maxTickCount,
          interval: spec.tickInterval,
        );
      }
      final nice = spec.nice ?? false;
      if (nice) {
        ticks = calcTicks;
        min = calcTicks.first;
        max = calcTicks.last;
      } else {
        final ticks = <num>[];
        for (var tick in calcTicks) {
          if (tick >= min! && tick <= max!) {
            ticks.add(tick);
          }
        }

        if (ticks.isEmpty) {
          ticks.add(min!);
          ticks.add(max!);
        }
      }
    }

    title = spec.title ?? variable;
    formatter = spec.formatter ?? defaultFormatter;
  }

  @override
  double convert(num input) =>
    (input - min!) / (max! - min!);

  @override
  num invert(double output) =>
    min! + output * (max! - min!);

  @override
  num get zero => 0;

  @override
  String defaultFormatter(num value) => value.toString();
}
