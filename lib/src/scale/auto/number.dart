import 'dart:math' as math;

import './util.dart';

const _minCount = 5;
const _maxCount = 7;
const _snapCountArray = [1, 1.2, 1.5, 1.6, 2, 2.2, 2.4, 2.5, 3, 4, 5, 6, 7.5, 8, 10];
const _snapArray = [1, 2, 4, 5, 10];
const eps = 1e-12;

class NumberAutoRst {
  NumberAutoRst(
    this.min,
    this.max,
    this.interval,
    this.count,
    this.ticks,
  );

  final num min;
  final num max;
  final num interval;
  final int count;
  final List<num> ticks;
}

NumberAutoRst numberAuto({
  num min = 0,
  num max = 0,
  num interval,
  num minTickInterval,
  int minCount = _minCount,
  int maxCount = _maxCount,
  num minLimit = double.negativeInfinity,
  num maxLimit = double.infinity,
  List<num> snapArray,
}) {
  final ticks = <num>[];
  minCount ??= _minCount;
  maxCount ??= _maxCount;
  final isFixedCount = minCount == maxCount;
  minLimit ??= double.negativeInfinity;
  maxLimit ??= double.infinity;
  var avgCount = (minCount + maxCount) ~/ 2;
  var count = avgCount;
  snapArray ??= (isFixedCount ? _snapCountArray : _snapArray);

  if (min == minLimit && max == maxLimit && isFixedCount) {
    interval = (max - min) / (count - 1);
  }

  if ((max - min).abs() < eps) {
    if (min == 0) {
      max = 1;
    } else {
      if (min > 0) {
        min = 0;
      } else {
        max = 0;
      }
    }
    if (max - min < 5 && interval == null && max - min >= 1) {
      interval = 1;
    }
  }

  if (interval == null) {
    final temp = (max - min) / (avgCount -1);
    interval = snapFactorTo(temp, snapArray, SnapType.ceil);
    if (maxCount != minCount) {
      count = (max - min) ~/ interval;
      count = count.clamp(minCount, maxCount);
      interval = snapFactorTo((max - min) / (count - 1), snapArray);
    }
  }

  if (minTickInterval != null && interval < minTickInterval) {
    interval = minTickInterval;
  }
  if (interval != null || maxCount != minCount) {
    max = math.min(snapMultiple(max, interval, SnapType.ceil), maxLimit);
    min = math.max(snapMultiple(min, interval, SnapType.floor), minLimit);

    count = ((max - min) / interval).round();
    min = fixedBase(min, interval);
    max = fixedBase(max, interval);

    num prevMin;
    while (min > minLimit && minLimit > double.negativeInfinity && (prevMin == null || min < prevMin)) {
      prevMin = min;
      min = fixedBase(min - interval, interval);
    }
  } else {
    avgCount = avgCount.floor();
    final avg = (max + min) / 2;
    final avgTick = snapMultiple(avg, interval, SnapType.ceil);
    final sideCount = (avgCount - 2) ~/ 2;
    var maxTick = avgTick + sideCount * interval;
    var minTick;
    if (avgCount % 2 == 0) {
      minTick = avgTick - sideCount * interval;
    } else {
      minTick = avgTick - (sideCount + 1) * interval;
    }

    num prevMaxTick;
    while (maxTick < max && (prevMaxTick == null || maxTick > prevMaxTick)) {
      prevMaxTick = maxTick;
      maxTick = fixedBase(maxTick + interval, interval);
    }

    num prevMinTick;
    while (minTick > min && (prevMinTick == null || minTick < prevMinTick)) {
      prevMinTick = minTick;
      minTick = fixedBase(minTick - interval, interval);
    }

    max = maxTick;
    min = minTick;
  }

  max = math.min(max, maxLimit);
  min = math.max(min, minLimit);

  ticks.add(min);
  for (var i = 1; i < count; i++) {
    final tickValue = fixedBase(interval * i + min, interval);
    if (tickValue < max) {
      ticks.add(tickValue);
    }
  }
  if (ticks.last < max) {
    ticks.add(max);
  }
  return NumberAutoRst(min, max, interval, count, ticks);
}
