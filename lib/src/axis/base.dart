import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/engine/render_shape/text.dart';
import 'package:meta/meta.dart';
import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/util/exception.dart';
import 'package:graphic/src/chart/component.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/scale/base.dart';

class AxisLine with TypedMap {
  AxisLine({
    bool top,
    LineStyle style,
  }) {
    this['top'] = top;
    this['style'] = style;
  }

  bool get top => this['top'] as bool ?? false;
  set top(bool value) => this['top'] = value;

  LineStyle get style => this['style'] as LineStyle;
  set style(LineStyle value) => this['style'] = value;
}

class AxisTickLine with TypedMap {
  AxisTickLine({
    bool top,
    LineStyle style,
    double length,
  }) {
    this['top'] = top;
    this['style'] = style;
    this['length'] = length;
  }

  bool get top => this['top'] as bool ?? false;
  set top(bool value) => this['top'] = value;

  LineStyle get style => this['style'] as LineStyle;
  set style(LineStyle value) => this['style'] = value;

  double get length => this['length'] as double;
  set length(double value) => this['length'] = value;
}

class AxisGrid with TypedMap {
  AxisGrid({
    bool top,
    LineStyle style,
  }) {
    this['top'] = top;
    this['style'] = style;
  }

  bool get top => this['top'] as bool ?? false;
  set top(bool value) => this['top'] = value;

  LineStyle get style => this['style'] as LineStyle;
  set style(LineStyle value) => this['style'] = value;

  bool get arc => this['arc'] as bool ?? false;
  set arc(bool value) => this['arc'] = value;
}

class AxisLabel with TypedMap {
  AxisLabel({
    bool top,
    TextStyle style,
    Offset offset,
    double rotation,
  }) {
    this['top'] = top;
    this['style'] = style;
    this['offset'] = offset;
    this['rotation'] = rotation;
  }

  bool get top => this['top'] as bool ?? false;
  set top(bool value) => this['top'] = value;

  TextStyle get style => this['style'] as TextStyle;
  set style(TextStyle value) => this['style'] = value;

  Offset get offset => this['offset'] as Offset;
  set offset(Offset value) => this['offset'] = value;

  double get rotation => this['rotation'] as double;
  set rotation(double value) => this['rotation'] = value;
}

class Axis with TypedMap {
  Axis({
    double position,
    AxisLine line,
    AxisTickLine tickLine,
    AxisGrid grid,
    AxisGrid Function(String text, int index, int total) gridCallback,
    AxisLabel label,
    AxisLabel Function(String text, int index, int total) labelCallback,
  }) {
    assert(
      testParamRedundant([grid, gridCallback]),
      paramRedundantWarning('grid, gridCallback'),
    );
    assert(
      testParamRedundant([label, labelCallback]),
      paramRedundantWarning('label, labelCallback'),
    );

    this['position'] = position;
    this['line'] = line;
    this['tickLine'] = tickLine;
    this['grid'] = grid;
    this['gridCallback'] = gridCallback;
    this['label'] = label;
    this['labelCallback'] = labelCallback;
  }
}

abstract class AxisState with TypedMap {
  ChartComponent get chart => this['chart'] as ChartComponent;
  set chart(ChartComponent value) => this['chart'] = value;

  ScaleComponent get scale => this['scale'] as ScaleComponent;
  set scale(ScaleComponent value) => this['scale'] = value;

  double get position => this['position'] as double;
  set position(double value) => this['position'] = value;

  AxisLine get line => this['line'] as AxisLine;
  set line(AxisLine value) => this['line'] = value;

  AxisTickLine get tickLine => this['tickLine'] as AxisTickLine;
  set tickLine(AxisTickLine value) => this['tickLine'] = value;

  AxisGrid get grid => this['grid'] as AxisGrid;
  set grid(AxisGrid value) => this['grid'] = value;

  AxisGrid Function(String text, int index, int total) get gridCallback =>
    this['gridCallback'] as AxisGrid Function(String text, int index, int total);
  set gridCallback(AxisGrid Function(String text, int index, int total) value) =>
    this['gridCallback'] = value;

  AxisLabel get label => this['label'] as AxisLabel;
  set label(AxisLabel value) => this['label'] = value;

  AxisLabel Function(String text, int index, int total) get labelCallback =>
    this['labelCallback'] as AxisLabel Function(String text, int index, int total);
  set labelCallback(AxisLabel Function(String text, int index, int total) value) =>
    this['labelCallback'] = value;
}

abstract class AxisComponent<S extends AxisState>
  extends Component<S>
{
  final _lineComponents = <RenderShapeComponent>[];

  final _tickLineComponents = <RenderShapeComponent>[];

  final _gridComponents = <RenderShapeComponent>[];

  final _labelComponents = <RenderShapeComponent>[];

  void render() {
    _renderLine();
    _renderTickLine();
    _renderGrid();
    _renderLabel();
  }

  void _renderLine() {
    if (_lineComponents.isNotEmpty) {
      for (var component in _lineComponents) {
        component.remove();
      }
      _lineComponents.clear();
    }

    if (state.line == null) {
      return;
    }

    final renderShapes = getLine();
    for (var renderShape in renderShapes) {
      final top = state.line.top;
      final plot = top
        ? state.chart.state.frontPlot
        : state.chart.state.backPlot;
      final component = plot.addShape(renderShape);
      _lineComponents.add(component);
    }
  }

  void _renderTickLine() {
    if (_tickLineComponents.isNotEmpty) {
      for (var component in _tickLineComponents) {
        component.remove();
      }
      _tickLineComponents.clear();
    }

    if (state.tickLine == null) {
      return;
    }

    final renderShapes = getTickLine();
    for (var renderShape in renderShapes) {
      final top = state.tickLine.top;
      final plot = top
        ? state.chart.state.frontPlot
        : state.chart.state.backPlot;
      final component = plot.addShape(renderShape);
      _tickLineComponents.add(component);
    }
  }

  void _renderGrid() {
    if (_gridComponents.isNotEmpty) {
      for (var component in _gridComponents) {
        component.remove();
      }
      _gridComponents.clear();
    }

    if (state.grid == null && state.gridCallback == null) {
      return;
    }

    final renderShapes = getGrid();
    final gridCallbackRsts = _gridCallbackRsts;
    for (var i = 0; i < renderShapes.length; i++) {
      final renderShape = renderShapes[i];
      final grid = state.gridCallback == null
        ? state.grid
        : gridCallbackRsts[i];
      final plot = grid.top
        ? state.chart.state.frontPlot
        : state.chart.state.backPlot;
      final component = plot.addShape(renderShape);
      _gridComponents.add(component);
    }
  }

  void _renderLabel() {
    if (_labelComponents.isNotEmpty) {
      for (var component in _labelComponents) {
        component.remove();
      }
      _labelComponents.clear();
    }

    if (state.label == null && state.labelCallback == null) {
      return;
    }

    final renderShapes = getLabel();
    final labelCallbackRsts = _labelCallbackRsts;
    for (var i = 0; i < renderShapes.length; i++) {
      final renderShape = renderShapes[i];
      final label = state.labelCallback == null
        ? state.label
        : labelCallbackRsts[i];
      final plot = label.top
        ? state.chart.state.frontPlot
        : state.chart.state.backPlot;
      final component = plot.addShape(renderShape);

      adjustLabel(component, label);
      final offset = label.offset;
      final rotation = label.rotation;
      if (offset != null) {
        component.translate(x: offset.dx, y: offset.dy);
      }
      if (rotation != null) {
        component.rotate(rotation, origin: component.bbox.topLeft);
      }

      _labelComponents.add(component);
    }
  }

  @protected
  void adjustLabel(TextRenderShapeComponent label, AxisLabel labelProps);

  @protected
  List<RenderShape> getLine();

  @protected
  List<RenderShape> getTickLine();

  @protected
  List<RenderShape> getGrid();

  @protected
  List<RenderShape> getLabel();

  List<AxisGrid> get _gridCallbackRsts {
    if (state.gridCallback == null) {
      return null;
    }

    final scale = state.scale;
    final ticks = scale.state.ticks;
    final total = ticks.length;
    final rst = <AxisGrid>[];
    for (var i = 0; i < total; i++) {
      final text = scale.getText(ticks[i]);
      final grid = state.gridCallback(text, i, total);
      if (grid != null) {
        rst.add(grid);
      }
    }
    return rst;
  }

  List<AxisLabel> get _labelCallbackRsts {
    if (state.labelCallback == null) {
      return null;
    }

    final scale = state.scale;
    final ticks = scale.state.ticks;
    final total = ticks.length;
    final rst = <AxisLabel>[];
    for (var i = 0; i < total; i++) {
      final text = scale.getText(ticks[i]);
      final label = state.labelCallback(text, i, total);
      if (label != null) {
        rst.add(label);
      }
    }
    return rst;
  }
}
