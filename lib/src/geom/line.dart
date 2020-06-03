import 'base.dart' show Geom;
import 'geom_cfg.dart' show GeomCfg, GeomType;
import 'shape/shape_cfg.dart' show ShapeCfg;
import 'adjust/adjust_cfg.dart' show AdjustType;
import 'shape/shape.dart' show ShapeFactoryBase;
import 'shape/util.dart' show spliteArray, splitPoints;

class Line extends Geom {
  Line(GeomCfg cfg) : super(cfg);

  @override
  GeomCfg get defaultCfg => super.defaultCfg
    ..type = GeomType.line
    ..sortable = true;

  @override
  ShapeCfg getDrawCfg(Map<String, Object> obj) {
    final cfg = super.getDrawCfg(obj);
    cfg.isStack = hasAdjust(AdjustType.stack);
    return cfg;
  }

  @override
  void drawData(List<Map<String, Object>> data, ShapeFactoryBase shapeFactory) {
    final container = cfg.container;
    final shapeCfg = getDrawCfg(data.first);
    final yScale = this.yScale;
    final connectNulls = cfg.connectNulls;
    final splitArray = spliteArray(data, yScale.cfg.field, connectNulls);
    // TODO: may need to add origin to ShapeCfg
    for (var i = 0; i < splitArray.length; i++) {
      final subData = splitArray[i];
      shapeCfg.splitedIndex = i;
      final points = subData.map((obj) {
        final x = obj['x'] as List<double>;
        final y = obj['y'] as List<double>;
        return splitPoints(x, y);
      });
      shapeCfg.points = points;
      drawShape(shapeCfg.shape, data.first, shapeCfg, container, shapeFactory);
    }
  }
}
