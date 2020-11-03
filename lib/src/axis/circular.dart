import 'dart:ui';

import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/line.dart';
import 'package:graphic/src/engine/render_shape/text.dart';
import 'package:graphic/src/engine/render_shape/arc.dart';

import 'base.dart';

class CircularAxisState extends AxisState {}

class CircularAxisComponent
  extends AxisComponent<CircularAxisState>
{
  @override
  CircularAxisState createState() => CircularAxisState();

  @override
  List<RenderShape> getLine() {
    final coord = state.chart.state.coord as PolarCoordComponent;
    final x = coord.center.dx;
    final y = coord.center.dy;
    final startAngle = coord.state.startAngle;
    final endAngle = coord.state.endAngle;
    final radius = coord.state.radius;
    final innerRadius = coord.state.innerRadius;
    final radiusLength = coord.radiusLength;
    final position = state.position;
    final r = ((radius - innerRadius) * position + innerRadius) * radiusLength;
    return [ArcRenderShape(
      x: x,
      y: y,
      r: r,
      startAngle: startAngle,
      endAngle: endAngle,
    )..mix(state.line.style)];
  }

  @override
  List<RenderShape> getTickLine() => [];

  @override
  List<RenderShape> getGrid() {
    final coord = state.chart.state.coord as PolarCoordComponent;
    final scale = state.scale;
    final ticks = scale.state.ticks;
    final count = ticks.length;
    final gridCallback = state.gridCallback;

    final rst = <RenderShape>[];
    if (gridCallback != null) {
      for (var i = 0; i < count; i++) {
        final tick = ticks[i];
        final scaledTick = scale.scale(tick);
        final text = scale.getText(tick);
        final grid = gridCallback(text, i, count);
        if (grid == null) {
          continue;
        }
        final startRenderPoint = coord.convertPoint(Offset(scaledTick, 0));
        final endRenderPoint = coord.convertPoint(Offset(scaledTick, 1));
        rst.add(LineRenderShape(
          x1: startRenderPoint.dx,
          y1: startRenderPoint.dy,
          x2: endRenderPoint.dx,
          y2: endRenderPoint.dy,
        )..mix(grid.style));
      }
    } else {
      for (var tick in ticks) {
        final scaledTick = scale.scale(tick);
        final startRenderPoint = coord.convertPoint(Offset(scaledTick, 0));
        final endRenderPoint = coord.convertPoint(Offset(scaledTick, 1));
        rst.add(LineRenderShape(
          x1: startRenderPoint.dx,
          y1: startRenderPoint.dy,
          x2: endRenderPoint.dx,
          y2: endRenderPoint.dy,
        )..mix(state.grid.style));
      }
    }
    return rst;
  }

  @override
  List<RenderShape> getLabel() {
    final coord = state.chart.state.coord as PolarCoordComponent;
    final scale = state.scale;
    final ticks = scale.state.ticks;
    final count = ticks.length;
    final labelCallback = state.labelCallback;
    final position = state.position;

    final rst = <RenderShape>[];
    if (labelCallback != null) {
      for (var i = 0; i < count; i++) {
        final tick = ticks[i];
        final scaledTick = scale.scale(tick);
        final text = scale.getText(tick);
        final label = labelCallback(text, i, count);
        if (label == null) {
          continue;
        }
        final renderPoint = coord.convertPoint(Offset(
          scaledTick,
          position,
        ));
        rst.add(TextRenderShape(
          x: renderPoint.dx,
          y: renderPoint.dy,
          text: text,
          textStyle: state.label.style,
        ));
      }
    } else {
      for (var tick in ticks) {
        final scaledTick = scale.scale(tick);
        final text = scale.getText(tick);
        final renderPoint = coord.convertPoint(Offset(
          scaledTick,
          position,
        ));
        rst.add(TextRenderShape(
          x: renderPoint.dx,
          y: renderPoint.dy,
          text: text,
          textStyle: state.label.style,
        ));
      }
    }
    return rst;
  }

  @override
  void adjustLabel(TextRenderShapeComponent label, AxisLabel labelProps) {
    final coord = state.chart.state.coord as PolarCoordComponent;
    final center = coord.center;
    final radiusX = label.state.x - center.dx;
    final radiusY = label.state.y - center.dy;
    final bbox = label.bbox;
    final biasX = bbox.center.dx - label.state.x;
    final biasY = bbox.center.dy - label.state.y;
    if (radiusX >= 0) {
      if (radiusY < 0) {
        // Quadrant 1
        label.translate(x: 0, y: -biasY * 2);
      }
        // Quadrant 2
        // Need no adjust
    } else {
      if (radiusY < 0) {
        // Quadrant 3
        label.translate(x: -biasX * 2, y: -biasY * 2);
      } else {
        // Quadrant 4
        label.translate(x: -biasX * 2, y: 0);
      }
    }
  }
}
