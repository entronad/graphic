import 'dart:ui';

import 'package:graphic/src/base.dart';
import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/engine/util/vector2.dart';
import 'package:graphic/src/engine/container.dart';
import 'package:graphic/src/engine/cfg.dart';
import 'package:graphic/src/engine/shape.dart';
import 'package:graphic/src/util/typed_map_mixin.dart';
import 'package:graphic/src/engine/shape/text.dart';
import 'package:graphic/src/scale/base.dart';

class GridPoint {
  GridPoint(this.points, this.id);

  List<Offset> points;

  String id;
}

enum AxisType {
  line,
  circle,
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
    if (line != null) this['line'] = line;
    if (labelOffset != null) this['labelOffset'] = labelOffset;
    if (grid != null) this['grid'] = grid;
    if (gridCallback != null) this['gridCallback'] = gridCallback;
    if (tickLine != null) this['tickLine'] = tickLine;
    if (label != null) this['label'] = label;
    if (labelCallback != null) this['labelCallback'] = labelCallback;
    if (position != null) this['position'] = position;
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

  // controller

  double get maxWidth => this['maxWidth'] as double;
  set maxWidth(double value) => this['maxWidth'] = value;

  double get maxHeight => this['maxHeight'] as double;
  set maxHeight(double value) => this['maxHeight'] = value;

  String get dimType => this['dimType'] as String;
  set dimType(String value) => this['dimType'] = value;

  Scale get verticalScale => this['verticalScale'] as Scale;
  set verticalScale(Scale value) => this['verticalScale'] = value;

  int get index => this['index'] as int;
  set index(int value) => this['index'] = value;
}


abstract class Axis<V> extends Base<AxisCfg> {
  Axis(AxisCfg cfg) : super(cfg) {
    draw();
  }

  @override
  AxisCfg get defaultCfg => AxisCfg()
    ..ticks = []
    ..tickLine = PaintCfg()
    ..offsetFactor = 1
    ..gridPoints = [];
  
  void draw() {
    final line = cfg.line;
    final tickLine = cfg.tickLine;
    final label = cfg.label;
    final grid = cfg.grid;
    final gridCallback = cfg.gridCallback;

    if (grid != null || gridCallback != null) {
      drawGrid(grid, gridCallback);
    }
    if (tickLine != null) {
      drawTicks(tickLine);
    }
    if (line != null) {
      drawLine(line);
    }
    if (label != null) {
      drawLabels();
    }
  }

  void drawTicks(PaintCfg tickCfg) {
    final ticks = cfg.ticks;
    final length = ticks.length;
    final container = getContainer(tickCfg.top);
    for (var tick in ticks) {
      final start = getOffsetPoint(tick.value);
      final end = getSidePoint(start, length);
      final shape = container.addShape(Cfg(
        type: 'line',
        attrs: Attrs(
          x1: start.dx,
          y1: start.dy,
          x2: end.dx,
          y2: end.dy,
        ).mix(tickCfg),
      ));
      shape.cfg.id = cfg.id + '-ticks';
    }
  }

  void drawLabels() {
    final labelOffset = cfg.labelOffset;
    final labels = cfg.labels;
    for (var labelShape in labels) {
      final container = getContainer(labelShape.cfg.top);
      final start = getOffsetPoint(labelShape.cfg.value);
      final point = getSidePoint(start, labelOffset);
      labelShape.attr(Attrs(
        x: point.dx,
        y: point.dy,
        textAlign: getTextAlignInfo(start, labelOffset),
      ).mix(labelShape.attrs));
      labelShape.cfg.id = cfg.id + '-' + (labelShape.attrs.textSpan?.toStringDeep() ?? labelShape.attrs.text);
      container.add(labelShape);
    }
  }

  void drawLine(PaintCfg lineCfg);

  void drawGrid(PaintCfg grid, PaintCfg Function(String text, int index, int total) gridCallback) {
    final gridPoints = cfg.gridPoints;
    final ticks = cfg.ticks;
    var gridCfg = grid;
    final count = gridPoints.length;

    for (var i = 0; i < count; i++) {
      final subPoints = gridPoints[i];
      if (gridCallback != null) {
        final tick = ticks[i] ?? Tick(null, null, null);
        final executedGrid = gridCallback(tick.text, i, count);
        gridCfg = executedGrid != null ? PaintCfg().mix(null).mix(executedGrid) : null;    // TODO: global theme
      }

      if (gridCfg != null) {
        final type = cfg.type;
        final points = subPoints.points;
        final container = getContainer(gridCfg.top);
        Shape shape;

        if (type == AxisType.circle) {
          final center = cfg.center;
          final startAngle = cfg.startAngle;
          final endAngle = cfg.endAngle;
          final radius = Vector2(points[0].dx - center.dx, points[0].dy - center.dy).length;
          shape = container.addShape(Cfg(
            type: 'arc',
            attrs: Attrs(
              x: center.dx,
              y: center.dy,
              startAngle: startAngle,
              endAngle: endAngle,
              r: radius,
            ).mix(gridCfg),
          ));
        } else {
          shape = container.addShape(Cfg(
            type: 'polyline',
            attrs: Attrs(points: points).mix(gridCfg),
          ));
        }

        shape.cfg.id = subPoints.id;
      }
    }
  }

  Offset getOffsetPoint(double value);

  Vector2 getAxisVector(Offset point);

  Vector2 getOffsetVector(Offset point, num offset) {
    final axisVector = getAxisVector(point);
    final normal = axisVector.normalized();
    final factor = cfg.offsetFactor;
    final verticalVector = Vector2(normal[1] * -1 * factor, normal[0] * factor);
    return verticalVector.scaled(offset);
  }

  Offset getSidePoint(Offset point, num offset) {
    final offsetVector = getOffsetVector(point, offset);
    return Offset(
      point.dx + offsetVector[0],
      point.dy + offsetVector[1],
    );
  }

  TextAlign getTextAlignInfo(Offset point, num offset) {
    final offsetVector = getOffsetVector(point, offset);
    TextAlign align;
    if (offsetVector[0] > 0) {
      align = TextAlign.start;
    } else if (offsetVector[0] < 0) {
      align = TextAlign.end;
    } else {
      align = TextAlign.center;
    }
    return align;
  }

  Container getContainer(bool isTop) =>
    isTop ? cfg.frontContainer : cfg.backContainer;
}
