import 'dart:ui';

import 'package:graphic/src/engine/container.dart';
import 'package:graphic/src/engine/shape.dart' as engine_shape;
import 'package:graphic/src/coord/base.dart';
import 'package:graphic/src/global.dart';
import 'package:graphic/src/util/typed_map_mixin.dart';
import 'package:graphic/src/engine/attrs.dart';

import '../base.dart';
import 'area.dart' as area;
import 'interval.dart' as interval;
import 'line.dart' as line;
import 'point.dart' as point;
import 'polygon.dart' as polygon;
import 'schema.dart' as schema;

class ShapeCfg with TypedMapMixin {

  // attr

  Color get color => this['color'] as Color;
  set color(Color value) => this['color'] = value;

  List<double> get x => this['x'] as List<double>;
  set x(List<double> value) => this['x'] = value;

  List<double> get y => this['y'] as List<double>;
  set y(List<double> value) => this['y'] = value;

  String get shape => this['shape'] as String;
  set shape(String value) => this['shape'] = value;

  double get size => this['size'] as double;
  set size(double value) => this['size'] = value;

  // others

  bool get isInCircle => this['isInCircle'] as bool ?? false;
  set isInCircle(bool value) => this['isInCircle'] = value;

  bool get isStack => this['isStack'] as bool ?? false;
  set isStack(bool value) => this['isStack'] = value;

  // one x can have multiple points
  List<List<Offset>> get points => this['points'] as List<List<Offset>>;
  set points(List<List<Offset>> value) => this['points'] = value;

  List<Offset> get nextPoints => this['nextPoints'] as List<Offset>;
  set nextPoints(List<Offset> value) => this['nextPoints'] = value;

  Attrs get style => this['style'] as Attrs;
  set style(Attrs value) => this['style'] = value;

  Offset get center => this['center'] as Offset;
  set center(Offset value) => this['center'] = value;

  double get y0 => this['y0'] as double;
  set y0(double value) => this['y0'] = value;

  int get splitedIndex => this['splitedIndex'] as int;
  set splitedIndex(int value) => this['splitedIndex'] = value;
}

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
    if (cfg.color == null) {
      cfg.color = Global.theme.colors.first;
    }
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
