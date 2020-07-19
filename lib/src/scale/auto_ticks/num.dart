import 'util.dart';

const _defaultMinCount = 5;
const _defaultMaxCount = 7;
const _defaultSnapCountList = [1, 1.2, 1.5, 1.6, 2, 2.2, 2.4, 2.5, 3, 4, 5, 6, 7.5, 8, 10];
const _defaultSnapList = [1, 2, 4, 5, 10];

const eps = 1e-12;

List<num> numAutoTicks({
  num minValue,
  num maxValue,
  num interval,
  num minTickInterval,
  int minCount,
  int maxCount,
  List<num> snapList,
}) {
  final ticks = <num>[];
  minValue ??= 0;
  maxValue ??= 0;
  minCount ??= _defaultMinCount;
  maxCount ??= _defaultMaxCount;
  final isFixedCount = (minCount == maxCount);
  var avgCount = (minCount + maxCount) ~/ 2;
  var count = avgCount;
  snapList ??= (isFixedCount ? _defaultSnapCountList : _defaultSnapList);

  if ((maxValue - minValue).abs() < eps) {
    if (minValue == 0) {
      maxValue = 1;
    } else {
      if (minValue > 0) {
        minValue = 0;
      } else {
        maxValue = 0;
      }
    }
    if (maxValue - minValue < 5 && interval == null && maxValue - minValue >= 1) {
      interval = 1;
    }
  }

  if (interval == null) {
    final temp = (maxValue - minValue) / (avgCount -1);
    interval = snapFactorTo(temp, snapList, SnapType.ceil);
    if (maxCount != minCount) {
      count = (maxValue - minValue) ~/ interval;
      count = count.clamp(minCount, maxCount);
      interval = snapFactorTo((maxValue - minValue) / (count - 1), snapList);
    }
  }

  if (minTickInterval != null && interval < minTickInterval) {
    interval = minTickInterval;
  }
  if (interval != null || maxCount != minCount) {
    maxValue = snapMultiple(maxValue, interval, SnapType.ceil);
    minValue = snapMultiple(minValue, interval, SnapType.floor);

    count = ((maxValue - minValue) / interval).round();
    minValue = fixedBase(minValue, interval);
    maxValue = fixedBase(maxValue, interval);
  } else {
    avgCount = avgCount.floor();
    final avg = (maxValue + minValue) / 2;
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
    while (maxTick < maxValue && (prevMaxTick == null || maxTick > prevMaxTick)) {
      prevMaxTick = maxTick;
      maxTick = fixedBase(maxTick + interval, interval);
    }

    num prevMinTick;
    while (minTick > minValue && (prevMinTick == null || minTick < prevMinTick)) {
      prevMinTick = minTick;
      minTick = fixedBase(minTick - interval, interval);
    }

    maxValue = maxTick;
    minValue = minTick;
  }

  ticks.add(minValue);
  for (var i = 1; i < count; i++) {
    final tickValue = fixedBase(interval * i + minValue, interval);
    if (tickValue < maxValue) {
      ticks.add(tickValue);
    }
  }
  if (ticks.last < maxValue) {
    ticks.add(maxValue);
  }

  return ticks;
}
