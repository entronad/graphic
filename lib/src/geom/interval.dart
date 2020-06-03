import 'base.dart' show Geom;
import 'geom_cfg.dart' show GeomCfg, GeomType;
import 'mixin/size_mixin.dart' show SizeMixin;

class Interval extends Geom with SizeMixin {
  Interval(GeomCfg cfg) : super(cfg);

  @override
  GeomCfg get defaultCfg => super.defaultCfg
    ..type = GeomType.interval
    ..generatePoints = true;

  @override
  void init() {
    super.init();
    initEvent();
  }

  @override
  Map<String, Object> createShapePointsCfg(Map<String, Object> obj) {
    final cfg = super.createShapePointsCfg(obj);
    cfg['size'] = getNormalizedSize(obj);
    return cfg;
  }

  @override
  void clearInner() {
    cfg.defaultSize = null;
    super.clearInner();
  }
}
