import 'base.dart';
import 'mixin/size_mixin.dart';

class Schema extends Geom with SizeMixin {
  Schema(GeomCfg cfg) : super(cfg);

  @override
  GeomCfg get defaultCfg => super.defaultCfg
    ..type = GeomType.schema
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
