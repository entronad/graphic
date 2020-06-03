import 'base.dart' show Geom;
import 'geom_cfg.dart' show GeomCfg, GeomType;

class Polygon extends Geom {
  Polygon(GeomCfg cfg) : super(cfg);

  @override
  GeomCfg get defaultCfg => super.defaultCfg
    ..type = GeomType.polygon
    ..generatePoints = true;
  
  @override
  Map<String, Object> createShapePointsCfg(Map<String, Object> obj) {
    final cfg = super.createShapePointsCfg(obj);
    var x = cfg['x'] as List<double>;
    var y = cfg['y'] as List<double>;
    List<double> temp;
    if (x.length == 1 || y.length == 1) {
      final xScale = this.xScale;
      final yScale = this.yScale;
      final xCount = xScale.cfg.values != null ? xScale.cfg.values.length : xScale.cfg.ticks.length;
      final yCount = yScale.cfg.values != null ? yScale.cfg.values.length : yScale.cfg.ticks.length;
      final xOffset = 0.5 * 1 / xCount;
      final yOffset = 0.5 * 1 / yCount;
      if (xScale.cfg.isCategory && yScale.cfg.isCategory) {
        x = [x.first - xOffset, x.first - xOffset, x.first + xOffset, x.first + xOffset];
        y = [y.first - yOffset, y.first + yOffset, y.first + yOffset, y.first - yOffset];
      } else if (x.length > 1) {
        temp = x;
        x = [temp[0], temp[0], temp[1], temp[1]];
        y = [y.first - yOffset / 2, y.first + yOffset / 2, y.first + yOffset / 2, y.first - yOffset / 2];
      } else if (y.length > 1) {
        temp = y;
        y = [temp[0], temp[1], temp[1], temp[0]];
        x = [x.length - xOffset / 2, x.length - xOffset / 2, x.length + xOffset / 2, x.length + xOffset / 2];
      }
      cfg['x'] = x;
      cfg['y'] = y;
    }
    return cfg;
  }
}
