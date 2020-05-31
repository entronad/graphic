import 'dart:ui' show Offset;

import 'package:graphic/src/engine/container.dart' show Container;
import 'package:graphic/src/engine/shape.dart' as engine_shape show Shape;
import 'package:graphic/src/coord/base.dart' show Coord;

import '../geom_cfg.dart' show GeomType;
import 'shape_cfg.dart' show ShapeCfg;
import 'area.dart' as area show AreaFactory, AreaShape, SmoothShape;
import 'interval.dart' as interval show
  IntervalFactory,
  RectShape,
  PyramidShape,
  FunnelShape;
import 'line.dart' as line show LineFactory, LineShape, SmoothShape;
import 'point.dart' as point show
  PointFactory,
  CircleShape,
  HollowCircleShape,
  RectShape;
import 'polygon.dart' as polygon show PolygonFactory, PolygonShape;
import 'schema.dart' as schema show SchemaFactory, CanleShape;

abstract class ShapeBase {
  Coord coord;

  List<engine_shape.Shape> draw(ShapeCfg cfg, Container container) =>
    drawShape(cfg, container);

  List<engine_shape.Shape> drawShape(ShapeCfg cfg, Container container) => null;

  Offset parsePoint(Offset point) {
    var biasedPoint = point;
    if (coord.cfg.isPolar) {
      var biasedX = point.dx;
      var biasedY = point.dy;
      if (point.dx == 1) {
        biasedX = 0.9999999;
      }
      if (point.dy == 1) {
        biasedY = 0.9999999;
      }
      biasedPoint = Offset(biasedX, biasedY);
    }
    return coord.convertPoint(biasedPoint);
  }

  List<Offset> parsePoints(List<Offset> points) {
    if (points = null) {
      return null;
    }
    final rst = <Offset>[];
    for (var point in points) {
      rst.add(parsePoint(point));
    }
    return rst;
  }

  List<Offset> getPoints(ShapeCfg cfg) => null;

  List<Offset> getShapePoints(ShapeCfg cfg) => null;
}

abstract class ShapeFactoryBase {
  final Map<String, ShapeBase> _shapes = {};

  Coord coord;

  GeomType get type;

  String get defaultShapeType => null;

  ShapeBase getShape(String type) {
    var shape = _shapes[type];
    if (shape == null) {
      final shapeCreator = Shape.shapes[this.type][type]
        ?? Shape.shapes[this.type][defaultShapeType];
      shape = shapeCreator();
      _shapes[type] = shape;
    }
    shape.coord = coord;
    return shape;
  }

  List<Offset> getShapePoints(String type, ShapeCfg cfg) {
    final shape = this.getShape(type);
    final points = shape.getPoints(cfg)
      ?? shape.getShapePoints(cfg)
      ?? getDefaultPoints(cfg);
    return points;
  }

  List<Offset> getDefaultPoints(ShapeCfg cfg) => [];

  List<engine_shape.Shape> drawShape(String type, ShapeCfg cfg, Container container) {
    final shape = this.getShape(type);
    // TODO: set default color to Global
    return shape.draw(cfg, container);
  }
}

abstract class Shape {
  static final Map<GeomType, ShapeFactoryBase Function()> factories = {
    GeomType.area: () => area.AreaFactory(),
    GeomType.interval: () => interval.IntervalFactory(),
    GeomType.line: () => line.LineFactory(),
    GeomType.point: () => point.PointFactory(),
    GeomType.polygon: () => polygon.PolygonFactory(),
    GeomType.schema: () => schema.SchemaFactory(),
  };

  static final Map<GeomType, Map<String, ShapeBase Function()>> shapes = {
    GeomType.area: {
      'area': () => area.AreaShape(),
      'smooth': () => area.SmoothShape(),
    },
    GeomType.interval: {
      'rect': () => interval.RectShape(),
      'pyramid': () => interval.PyramidShape(),
      'funnel': () => interval.FunnelShape(),
    },
    GeomType.line: {
      'line': () => line.LineShape(),
      'smooth': () => line.SmoothShape(),
    },
    GeomType.point: {
      'circle': () => point.CircleShape(),
      'hollowCircle': () => point.HollowCircleShape(),
      'rect': () => point.RectShape(),
    },
    GeomType.polygon: {
      'polygon': () => polygon.PolygonShape(),
    },
    GeomType.schema: {
      'candle': () => schema.CanleShape(),
    },
  };

  static void registerShape (
    GeomType factoryName,
    String shapeType,
    ShapeBase Function() shapeCreator,
  ) {
    assert(factories.containsKey(factoryName));

    if (!shapes.containsKey(factoryName)) {
      shapes[factoryName] = {};
    }
    shapes[factoryName][shapeType] = shapeCreator;
  }

  static ShapeFactoryBase Function() getShapeFctory(GeomType factoryName) =>
    factories[factoryName];
}
