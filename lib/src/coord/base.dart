import 'dart:ui';

import 'package:graphic/src/base.dart';
import 'package:graphic/src/engine/util/matrix.dart';
import 'package:graphic/src/engine/util/vector2.dart';
import 'package:graphic/src/util/typed_map_mixin.dart';

import 'polar_coord.dart';
import 'rect_coord.dart';

final defaultMatrix = Matrix.identity();

enum CoordType {
  rect,
  polar,
}

class CoordCfg with TypedMapMixin {
  CoordCfg({
    CoordType type,
    bool transposed,
    double startAngle,
    double endAngle,
    double innerRadius,
    double radius,
    List<double> scale,
  }) {
    if (type != null) this['type'] = type;
    if (transposed != null) this['transposed'] = transposed;
    if (startAngle != null) this['startAngle'] = startAngle;
    if (endAngle != null) this['endAngle'] = endAngle;
    if (innerRadius != null) this['innerRadius'] = innerRadius;
    if (radius != null) this['radius'] = radius;
    if (scale != null) this['scale'] = scale;
  }

  // base

  CoordType get type => this['type'] as CoordType;
  set type(CoordType value) => this['type'] = value;

  bool get isRect => this['isRect'] as bool ?? false;
  set isRect(bool value) => this['isRect'] = value;

  bool get isPolar => this['isPolar'] as bool ?? false;
  set isPolar(bool value) => this['isPolar'] = value;

  bool get transposed => this['transposed'] as bool ?? false;
  set transposed(bool value) => this['transposed'] = value;

  Rect get plot => this['plot'] as Rect;
  set plot(Rect value) => this['plot'] = value;

  Offset get start => this['start'] as Offset;
  set start(Offset value) => this['start'] = value;

  Offset get end => this['end'] as Offset;
  set end(Offset value) => this['end'] = value;

  List<double> get x => this['x'] as List<double>;
  set x(List<double> value) => this['x'] = value;

  List<double> get y => this['y'] as List<double>;
  set y(List<double> value) => this['y'] = value;

  // polar

  Offset get center => this['center'] as Offset;
  set center(Offset value) => this['center'] = value;

  double get radius => this['radius'] as double;
  set radius(double value) => this['radius'] = value;

  double get innerRadius => this['innerRadius'] as double;
  set innerRadius(double value) => this['innerRadius'] = value;

  double get startAngle => this['startAngle'] as double;
  set startAngle(double value) => this['startAngle'] = value;

  double get endAngle => this['endAngle'] as double;
  set endAngle(double value) => this['endAngle'] = value;

  double get circleRadius => this['circleRadius'] as double;
  set circleRadius(double value) => this['circleRadius'] = value;

  Matrix get matrix => this['matrix'] as Matrix;
  set matrix(Matrix value) => this['matrix'] = value;

  List<double> get scale => this['scale'] as List<double>;
  set scale(List<double> value) => this['scale'] = value;
}

abstract class Coord extends Base<CoordCfg> {
  static final Map<CoordType, Coord Function(CoordCfg)> creators = {
    CoordType.polar: (CoordCfg cfg) => PolarCoord(cfg),
    CoordType.rect: (CoordCfg cfg) => RectCoord(cfg),
  };

  Coord(CoordCfg cfg) : super(cfg) {
    Offset start;
    Offset end;
    if (cfg.plot != null) {
      start = cfg.plot.bottomLeft;
      end = cfg.plot.topRight;
      cfg.start = start;
      cfg.end = end;
    } else {
      start = cfg.start;
      end = cfg.end;
    }
    this.init(start, end);
  }

  void _scale(List<double> scale) {
    final matrix = cfg.matrix;
    final centerV = Vector2.fromOffset(cfg.center);
    final scaleV = Vector2.array(scale);
    matrix.translate(centerV);
    matrix.scale(scaleV);
    matrix.translate(-centerV);
  }

  void init(Offset start, Offset end) {
    cfg.matrix = defaultMatrix.clone();
    cfg.center = Offset(
      ((end.dx - start.dx) / 2) + start.dx,
      (end.dy - start.dy) / 2 + start.dy
    );
    if (cfg.scale != null) {
      _scale(cfg.scale);
    }
  }

  Offset convertPoint(Offset point) {
    final convertedPoint = convertPointInner(point);
    final vector = Vector2.fromOffset(convertedPoint);
    vector.transformMat2d(cfg.matrix);

    return Offset(vector.x, vector.y);
  }

  Offset invertPoint(Offset point) =>
    invertPointInner(point);

  Offset convertPointInner(Offset point);

  Offset invertPointInner(Offset point);

  void reset(Rect plot) {
    cfg.plot = plot;
    cfg.start = plot.bottomLeft;
    cfg.end = plot.topRight;
    init(plot.bottomLeft, plot.topRight);
  }
}
