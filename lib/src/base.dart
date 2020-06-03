import 'package:graphic/src/util/typed_map_mixin.dart' show TypedMapMixin;

abstract class Base<C extends TypedMapMixin> {
  Base(C cfg) {
    this.cfg = defaultCfg;
    this.cfg.mix(cfg);
  }

  C cfg;

  C get defaultCfg;
}
