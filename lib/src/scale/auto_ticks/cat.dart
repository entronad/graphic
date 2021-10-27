import 'package:graphic/src/util/list.dart';

const _defaultMaxCount = 8;

const _subCount = 4;

int _getGreatestFactor(int count, int number) {
  var i;
  for (i = number; i > 0; i--) {
    if (count % i == 0) {
      break;
    }
  }
  if (i == 1) {
    for (i = number; i > 0; i--) {
      if ((count - 1) % i == 0) {
        break;
      }
    }
  }
  return i;
}

List<V> catAutoTicks<V>({
  required List<V> categories,
  bool? isRounding,
  int? maxCount,
}) {
  isRounding ??= false;
  maxCount ??= _defaultMaxCount;

  final ticks = <V>[];
  final length = categories.length;
  int tickCount;

  if (isRounding) {
    tickCount = _getGreatestFactor(length - 1, maxCount - 1) + 1;
    if (tickCount == 2) {
      tickCount = maxCount;
    } else if (tickCount < maxCount - _subCount) {
      tickCount = maxCount - _subCount;
    }
  } else {
    tickCount = maxCount;
  }

  if (!isRounding && length <= tickCount + tickCount / 2) {
    ticks.addAll(categories);
  } else {
    final step = (length / (tickCount - 1)).floor();

    var i = 0;
    final groups = categories.map((e) {
      final rst = (i % step == 0) ? sublist(categories, i, i + step) : null;
      i++;
      return rst;
    }).where((e) {
      return e != null;
    }).toList();

    for (var i = 1, groupLen = groups.length;
        (i < groupLen) &&
            (isRounding ? i * step < length - step : i < tickCount - 1);
        i++) {
      ticks.add(groups[i]![0]);
    }
    if (categories.isNotEmpty) {
      ticks.insert(0, categories[0]);
      final last = categories.last;
      if (!ticks.contains(last)) {
        ticks.add(last);
      }
    }
  }

  return ticks;
}
