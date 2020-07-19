const _maxDecimalLength = 12;

double _getFactor(num v) {
  var factor = 1.0;
  if (v == double.infinity || v == double.negativeInfinity) {
    throw Exception('Not support Infinity.');
  }
  if (v < 1) {
    var count = 0;
    while (v < 1) {
      factor = factor / 10;
      v = v * 10;
      count++;
    }
    if (factor.toString().length > _maxDecimalLength) {
      factor = double.parse(factor.toStringAsFixed(count));
    }
  } else {
    while (v > 10) {
      factor = factor * 10;
      v = v / 10;
    }
  }

  return factor;
}

// Less then current value.
num _listFloor(List<num> values, num value) {
  if (values == null || values.length == 0) {
    return double.nan;
  }

  var pre = values[0];

  if (value < values[0]) {
    return double.nan;
  }

  if (value >= values.last) {
    return values.last;
  }
  for (var v in values) {
    if (value < v) {
      break;
    }
    pre = v;
  }

  return pre;
}

// First greater then current value.
num _listCeiling(List<num> values, num value) {
  if (values == null || values.length == 0) {
    return double.nan;
  }

  var rst;

  if (value > values.last) {
    return double.nan;
  }

  if (value < values[0]) {
    return values[0];
  }
  for (var v in values) {
    if (value <= v) {
      rst = v;
      break;
    }
  }

  return rst;
}

enum SnapType {
  floor,
  ceil,
}

num snapTo(List<num> values, num value) {
  if (values == null || values.length == 0) {
    return double.nan;
  }
  final floorVal = _listFloor(values, value);
  final ceilingVal = _listCeiling(values, value);
  if (floorVal.isNaN || ceilingVal.isNaN) {
    if (values[0] >= value) {
      return values[0];
    }
    final last = values.last;
    if (last <= value) {
      return last;
    }
  }
  if ((value - floorVal).abs() < (ceilingVal - value).abs()) {
    return floorVal;
  }
  return ceilingVal;
}

num snapFloor(List<num> values, num value) =>
  _listFloor(values, value);

num snapCeiling(List<num> values, num value) =>
  _listCeiling(values, value);

num snapFactorTo(num v, List<num> arr, [SnapType snapType]) {
  if (v.isNaN) {
    return double.nan;
  }
  var factor = 1.0;
  if (v != 0) {
    if (v < 0) {
      factor = -1;
    }
    v = v * factor;
    final tmpFactor = _getFactor(v);
    factor = factor * tmpFactor;

    v = v / tmpFactor;
  }
  if (snapType == SnapType.floor) {
    v = snapFloor(arr, v);
  } else if (snapType == SnapType.ceil) {
    v = snapCeiling(arr, v);
  } else {
    v = snapTo(arr, v);
  }
  var rst = double.parse((v * factor).toStringAsPrecision(_maxDecimalLength));
  if (factor.abs() < 1 && rst.toString().length > _maxDecimalLength) {
    final decimalVal = 1 ~/ factor;
    final symbol = factor > 0 ? 1 : -1;
    rst = v / decimalVal * symbol;
  }
  return rst;
}

num snapMultiple(num v, num base, [SnapType snapType]) {
  var div;
  if (snapType == SnapType.ceil) {
    div = (v / base).ceil();
  } else if (snapType == SnapType.floor) {
    div = (v / base).floor();
  } else {
    div = (v / base).round();
  }
  return div * base;
}

num fixedBase(num v, num base) {
  final str = base.toString();

  if (base is int) {
    return v.round();
  }
  final index = str.indexOf('.');
  final indexOfExp = str.indexOf('e-');
  var length = indexOfExp >= 0
    ? int.parse(str.substring(indexOfExp + 2), radix: 10)
    : str.substring(index + 1).length;
  if (length > 20) {
    length = 20;
  }
  return num.parse(v.toStringAsFixed(length));
}
