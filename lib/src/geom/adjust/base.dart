import 'adjust_cfg.dart' show AdjustCfg, AdjustType;
import 'dodge.dart' show Dodge;
import 'stack.dart' show Stack;
import 'symmetric.dart' show Symmetric;

abstract class Adjust {
  static final creators = {
    AdjustType.dodge: (AdjustCfg cfg) => Dodge(cfg),
    AdjustType.stack: (AdjustCfg cfg) => Stack(cfg),
    AdjustType.symmetric: (AdjustCfg cfg) => Symmetric(cfg),
  };

  Adjust(AdjustCfg cfg) {
    this.cfg = defaultCfg.mix(cfg);
  }

  AdjustCfg cfg;

  AdjustCfg get defaultCfg => AdjustCfg()
    ..adjustNames = ['x', 'y'];

  void processAdjust(List<List<Map<String, Object>>> dataArray);
}

