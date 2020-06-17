import 'cfg.dart';
import 'container.dart';

class Group extends Container {
  Group(Cfg cfg) : super(cfg);

  @override
  Cfg get defaultCfg => Cfg()
    ..zIndex = 0
    ..visible = true
    ..destroyed = false
    ..isGroup = true
    ..children = [];

  @override
  void destroy() {
    if (cfg.destroyed) {
      return;
    }
    clear();
    super.destroy();
  }
}
