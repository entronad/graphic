import 'base.dart' show Geom;
import 'geom_cfg.dart' show GeomCfg, GeomType;
import 'adjust/adjust_cfg.dart' show AdjustType;
import 'shape/shape.dart' show ShapeFactoryBase;

class Point extends Geom {
  Point(GeomCfg cfg) : super(cfg);

  @override
  GeomCfg get defaultCfg => super.defaultCfg
    ..type = GeomType.point
    ..generatePoints = false;

  @override
  void drawData(List<Map<String, Object>> data, ShapeFactoryBase shapeFactory) {
    final container = cfg.container;
    for (var obj in data) {
      final shape = obj['shape'] as String;
      final shapeCfg = getDrawCfg(obj);
      final hasStack = hasAdjust(AdjustType.stack);
      final yList = obj['y'] as List<double>;
      for (var i = 0; i < yList.length; i++) {
        final y = yList[i];
        shapeCfg.y = [y];
        if (!hasStack || i != 0) {
          drawShape(shape, obj, shapeCfg, container, shapeFactory);
        }
      }
    }
  }
}
