import 'base.dart';

const marginRatio = 1 / 2;
const dodgeRatio = 1 / 2;

class Dodge extends Adjust {
  Dodge(AdjustCfg cfg) : super(cfg);

  @override
  AdjustCfg get defaultCfg => super.defaultCfg
    ..marginRatio = marginRatio
    ..dodgeRatio = dodgeRatio;
  
  double getDodgeOffset(List<num> range, int index, int count) {
    final pre = range.first;
    final next = range.last;
    final tickLength = next - pre;
    final width = (tickLength * cfg.dodgeRatio) / count;
    final margin = cfg.marginRatio * width;
    final offset = 1 / 2 * (tickLength - (count) * width - (count - 1) * margin) +
      ((index + 1) * width + index * margin) -
      1 / 2 * width - 1 / 2 * tickLength;
    return (pre + next) / 2 + offset;
  }

  @override
  void processAdjust(List<List<Map<String, Object>>> dataArray) {
    final count = dataArray.length;
    final xField = cfg.xField;
    for (var index = 0; index < dataArray.length; index++) {
      final data = dataArray[index];
      for (var i = 0, len = data.length; i < len; i++) {
        final obj = data[i];
        final value = obj[xField] as num;
        final range = [
          len == 1 ? value - 1 : value - 0.5,
          len == 1 ? value + 1 : value + 0.5,
        ];
        final dodgeValue = getDodgeOffset(range, index, count);
        obj[xField] = dodgeValue;
      }
    }
  }
}
