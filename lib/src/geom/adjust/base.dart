import 'adjust_cfg.dart' show AdjustCfg;

enum AdjustType {
  dodge,
  stack,
  symmetric,
}

abstract class Adjust {
  Adjust(AdjustCfg cfg) {
    this.cfg = defaultCfg.mix(cfg);
  }

  AdjustCfg cfg;

  AdjustCfg get defaultCfg => AdjustCfg()
    ..adjustNames = ['x', 'y'];

  void processAdjust(List<List<Map<String, Object>>> dataArray);
}

