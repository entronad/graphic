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
    double? marginMin,
    double? marginMax,

    String? title,
    String Function(num)? formatter,
    List<num>? ticks,
    int? tickCount,
    int? maxTickCount,
  }) : super(
    min: min,
    max: max,
    marginMin: marginMin,
    marginMax: marginMax,
    title: title,
    formatter: formatter,
    ticks: ticks,
    tickCount: tickCount,
    maxTickCount: maxTickCount,
  );

  num? tickInterval;

  bool? nice;

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
      // Can't use the first one in case it is nan.
      num minTmp = double.infinity;
      num maxTmp = double.negativeInfinity;
      for (var tuple in tuples) {
        final value = tuple[variable] as num;
        if (!value.isNaN) {
          minTmp = math.min(minTmp, value);
          maxTmp = math.max(maxTmp, value);
        }
      }

      final range = maxTmp - minTmp;
      final marginMin = range * (spec.marginMin ?? 0.1);  // TODO: default
      final marginMax = range * (spec.marginMax ?? 0.1);  // TODO: default
      min = spec.min ?? minTmp - marginMin;
      max = spec.max ?? maxTmp + marginMax;
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
        ticks = [];
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

  @override
  bool operator ==(Object other) =>
    other is LinearScaleConv &&
    super == other;
}
