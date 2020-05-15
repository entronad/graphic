import 'engine/event/event_emitter.dart' show EventEmitter;
import 'util/typed_map_mixin.dart' show TypedMapMixin;

class BaseCfg with TypedMapMixin {
  BaseCfg({
    bool destroyed,
  }) {
    this['destroyed'] = destroyed;
  }

  bool get destroyed => this['destroyed'] as bool ?? false;
  set destroyed(bool value) => this['destroyed'] = value;
}

abstract class Base with EventEmitter {
  Base(BaseCfg cfg) {
    this.cfg = defaultCfg;
    this.cfg.mix(cfg);
  }

  BaseCfg cfg;

  BaseCfg get defaultCfg;

  bool get destroyed => cfg.destroyed;

  void destroy() {
    cfg = BaseCfg();
    cfg.destroyed = true;
  }
}
