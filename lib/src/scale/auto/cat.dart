import 'dart:math' show min;

const _maxCount = 8;
const _subCount = 4;

List _getSimpleArray(List data) {
  if (data.first is List) {
    return data.expand((item) => item).toList();
  }
  return List.from(data);
}
  

int _getGreatestFactor(int count, int number) {
  var i;
  for (i = number; i > 0; i--) {
    if (count % i == 0) {
      break;
    }
  }
  if (i == 1) {
    for (i = number; i > 0; i --) {
      if ((count - 1) % i == 0) {
        break;
      }
    }
  }
  return i;
}

class CatAutoRst {
  CatAutoRst(this.categories, this.ticks);

  final List categories;
  final List ticks;
}

CatAutoRst catAuto<F>({bool isRounding = false, List data, int maxCount = _maxCount}) {
  var ticks = <F>[];
  final categories = _getSimpleArray(data);
  final length = categories.length;
  var tickCount;

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
    ticks = List.from(categories);
  } else {
    final step = (length / (tickCount - 1)).floor();

    var i = 0;
    final groups = categories.map((e) {
      final rst = (i % step == 0) ? categories.sublist(i, min(i + step, length)) : null;
      i++;
      return rst;
    }).where((e) {
      return e != null;
    }).toList();

    for (
      var i = 1, groupLen = groups.length;
      (i < groupLen) && (isRounding ? i * step < length - step : i < tickCount -1);
      i++
    ) {
      ticks.add(groups[i][0]);
    }
    if (categories.isNotEmpty) {
      ticks.insert(0, categories[0]);
      final last = categories.last;
      if (!ticks.contains(last)) {
        ticks.add(last);
      }
    }
  }

  return CatAutoRst(categories, ticks);
}
