import 'base.dart' show Adjust;
import 'adjust_cfg.dart' show AdjustCfg;

class Stack extends Adjust {
  Stack(AdjustCfg cfg) : super(cfg);
  
  @override
  void processAdjust(List<List<Map<String, Object>>> dataArray) =>
    this.processStack(dataArray);
  
  void processStack(List<List<Map<String, Object>>> dataArray) {
    final xField = cfg.xField;
    final yField = cfg.yField;
    final count = dataArray.length;
    final stackCache = {
      'positive': <String, num>{},
      'negative': <String, num>{},
    };
    if (cfg.reverseOrder) {
      dataArray = dataArray.sublist(0).reversed.toList();
    }
    for (var i = 0; i < count; i++) {
      final data = dataArray[i];
      for (var j = 0, len = data.length; j < len; j++) {
        final item = data[j];
        final x = item[xField] ?? 0;
        final yRaw = item[yField];
        final xKey = x.toString();
        final y = yRaw is List ? yRaw[1] : yRaw;
        if (y != null) {
          final yNum = y as num;
          final direction = yNum >= 0 ? 'positive' : 'negative';
          if (stackCache[direction][xKey] == null) {
            stackCache[direction][xKey] = 0;
          }
          item[yField] = [stackCache[direction][xKey], yNum + stackCache[direction][xKey]];
          stackCache[direction][xKey] += yNum;
        }
      }
    }
  }
}
