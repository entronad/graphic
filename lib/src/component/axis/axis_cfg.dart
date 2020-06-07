import 'dart:ui' show Offset;

import 'package:graphic/src/util/typed_map_mixin.dart' show TypedMapMixin;
import 'package:graphic/src/engine/attrs.dart' show PaintCfg, TextCfg;
import 'package:graphic/src/engine/container.dart' show Container;
import 'package:graphic/src/engine/shape/text.dart' show Text;

enum AxisType {
  line,
  circle,
}

class Tick<V> {
  Tick(this.text, this.tickValue, this.value);

  String text;

  V tickValue;

  double value;
}

class GridPoint {
  GridPoint(this.points, this.id);

  List<Offset> points;

  String id;
}

class AxisCfg<F> with TypedMapMixin {
  AxisCfg({
    PaintCfg line,
    double labelOffset,
    PaintCfg grid,
    PaintCfg Function(String text, int index, int total) gridCallback,
    PaintCfg tickLine,
    TextCfg label,
    TextCfg Function(String text, int index, int total) labelCallback,
    String position,
  }) {
    this['line'] = line;
    this['labelOffset'] = labelOffset;
    this['grid'] = grid;
    this['gridCallback'] = gridCallback;
    this['tickLine'] = tickLine;
    this['label'] = label;
    this['labelCallback'] = labelCallback;
    this['position'] = position;
  }

  PaintCfg get line => this['line'] as PaintCfg;
  set line(PaintCfg value) => this['line'] = value;

  double get labelOffset => this['labelOffset'] as double;
  set labelOffset(double value) => this['labelOffset'] = value;

  PaintCfg get grid => this['grid'] as PaintCfg;
  set grid(PaintCfg value) => this['grid'] = value;

  PaintCfg Function(String text, int index, int total) get gridCallback =>
    this['gridCallback'] as PaintCfg Function(String text, int index, int total);
  set gridCallback(PaintCfg Function(String text, int index, int total) value) => this['gridCallback'] = value;

  PaintCfg get tickLine => this['tickLine'] as PaintCfg;
  set tickLine(PaintCfg value) => this['tickLine'] = value;

  TextCfg get label => this['label'] as TextCfg;
  set label(TextCfg value) => this['label'] = value;

  TextCfg Function(String text, int index, int total) get labelCallback =>
    this['labelCallback'] as TextCfg Function(String text, int index, int total);
  set labelCallback(TextCfg Function(String text, int index, int total) value) => this['labelCallback'] = value;

  String get position => this['position'] as String;
  set position(String value) => this['position'] = value;

  // abstract

  List<Tick> get ticks => this['ticks'] as List<Tick>;
  set ticks(List<Tick> value) => this['ticks'] = value;

  int get offsetFactor => this['offsetFactor'] as int;
  set offsetFactor(int value) => this['offsetFactor'] = value;

  Container get frontContainer => this['frontContainer'] as Container;
  set frontContainer(Container value) => this['frontContainer'] = value;

  Container get backContainer => this['backContainer'] as Container;
  set backContainer(Container value) => this['backContainer'] = value;

  List<GridPoint> get gridPoints => this['gridPoints'] as List<GridPoint>;
  set gridPoints(List<GridPoint> value) => this['gridPoints'] = value;

  String get id => this['id'] as String;
  set id(String value) => this['id'] = value;

  List<Text> get labels => this['labels'] as List<Text>;
  set labels(List<Text> value) => this['labels'] = value;

  AxisType get type => this['type'] as AxisType;
  set type(AxisType value) => this['type'] = value;

  // circle

  double get startAngle => this['startAngle'] as double;
  set startAngle(double value) => this['startAngle'] = value;

  double get endAngle => this['endAngle'] as double;
  set endAngle(double value) => this['endAngle'] = value;

  double get radius => this['radius'] as double;
  set radius(double value) => this['radius'] = value;

  Offset get center => this['center'] as Offset;
  set center(Offset value) => this['center'] = value;

  // line

  Offset get start => this['start'] as Offset;
  set start(Offset value) => this['start'] = value;

  Offset get end => this['end'] as Offset;
  set end(Offset value) => this['end'] = value;
}
