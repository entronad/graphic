import './event/event_emitter.dart' show EventEmitter;
import 'cfg.dart' show Cfg;

abstract class Base extends EventEmitter {
  Base(Cfg cfg){
    this.cfg = defaultCfg.mix(cfg);
  } 

  Cfg cfg;

  bool destroyed = false;

  Cfg get defaultCfg => Cfg();

  void destroy() {
    cfg = Cfg(destroyed: true);
    off();
    destroyed = true;
  }
}

typedef Ctor<T extends Base> = T Function(Cfg ctf);
