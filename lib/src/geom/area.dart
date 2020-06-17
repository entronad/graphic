import 'base.dart';
import 'shape/shape.dart';
import 'shape/util.dart';

class Area extends Geom {
  Area(GeomCfg cfg) : super(cfg);

  @override
  GeomCfg get defaultCfg => super.defaultCfg
    ..type = GeomType.area
    ..generatePoints = true
    ..sortable = true;
  
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
      final points = subData.map((obj) => obj['points']);
      shapeCfg.points = points;
      drawShape(shapeCfg.shape, data.first, shapeCfg, container, shapeFactory);
    }
  }
}
