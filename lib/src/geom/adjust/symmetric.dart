import 'dart:math' show max;

import 'base.dart' show Adjust;
import 'adjust_cfg.dart' show AdjustCfg;

List<Map<String, Object>> flattern(List<List<Map<String, Object>>> dataArray) {
  final rst = <Map<String, Object>>[];
  for (var data in dataArray) {
    rst.addAll(data);
  }
  return rst;
}

Map<String, Object> maxBy(
  List<Map<String, Object>> data,
  num Function(Map<String, Object>) fn,
) {
  var max = data.first;
  num maxValue = fn(data.first);
  num currentValue;
  for (var current in data) {
    currentValue = fn(current);
    if (currentValue > maxValue) {
      max = current;
      maxValue = currentValue;
    }
  }
  return max;
}

class Symmetric extends Adjust {
  Symmetric(AdjustCfg cfg) : super(cfg);

  List<Map<String, Object>> _flatData;

  @override
  AdjustCfg get defaultCfg => super.defaultCfg
    ..adjustNames = ['y'];

  num _getMax(String dim) {
    final maxRecord = maxBy(_flatData, (obj) {
      final value = obj[dim];
      if (value is List<num>) {
        return value.reduce(max);
      }
      return value;
    });
    final maxValue = maxRecord[dim];
    final rst = (maxValue is List<num>) ? maxValue.reduce(max) : maxValue;
    return rst;
  }

  Map<Object, Object> _getXValuesMax() {
    final xField = cfg.xField;
    final yField = cfg.yField;
    final cache = <Object, Object>{};
    for (var obj in _flatData) {
      final xValue = obj[xField];
      final yValue = obj[yField];
      final yMax = (yValue is List<num>) ? yValue.reduce(max) : yValue;
      cache[xValue] = cache[xValue] ?? 0;
      if ((cache[xValue] as num) < yMax) {
        cache[xValue] = yMax;
      }
    }
    return cache;
  }
  
  @override
  void processAdjust(List<List<Map<String, Object>>> dataArray) {
    _flatData = flattern(dataArray);
    _processSymmetric(dataArray);
    _flatData = null;
  }
  
  void _processSymmetric(List<List<Map<String, Object>>> dataArray) {
    final xField = cfg.xField;
    final yField = cfg.yField;
    final maxRst = _getMax(yField);
    final first = dataArray.first.first;

    Map<Object, Object> cache;
    if (first != null && (first[yField] is List)) {
      cache = _getXValuesMax();
    }
    for (var data in dataArray) {
      for (var obj in data) {
        final value = obj[yField];
        num offset;
        if (value is List) {
          final xValue = obj[xField];
          final valueMax = cache[xValue];
          offset = (maxRst - valueMax) / 2;
          final tmp = <num>[];
          for (var subVal in value) {
            tmp.add(offset + subVal);
          }
          obj[yField] = tmp;
        } else {
          final valueNum = value as num;
          offset = (maxRst - valueNum) / 2;
          obj[yField] = [offset, valueNum + offset];
        }
      }
    }
  }
}
