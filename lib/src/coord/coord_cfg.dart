import 'dart:ui' show Rect, Offset;

import 'package:graphic/src/util/typed_map_mixin.dart' show TypedMapMixin;
import 'package:graphic/src/engine/util/matrix.dart' show Matrix;

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
    this['type'] = type;
    this['transposed'] = transposed;
    this['startAngle'] = startAngle;
    this['endAngle'] = endAngle;
    this['innerRadius'] = innerRadius;
    this['radius'] = radius;
    this['scale'] = scale;
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
