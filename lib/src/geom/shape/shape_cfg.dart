import 'dart:ui' show Color, Offset;

import 'package:graphic/src/util/typed_map_mixin.dart' show TypedMapMixin;
import 'package:graphic/src/engine/attrs.dart' show Attrs;

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
}
