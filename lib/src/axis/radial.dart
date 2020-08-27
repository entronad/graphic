import 'dart:ui';

import 'package:graphic/src/coord/polar.dart';
import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/line.dart';
import 'package:graphic/src/engine/render_shape/text.dart';
import 'package:graphic/src/engine/render_shape/arc.dart';

import 'base.dart';

class RadialAxisState extends AxisState {}

class RadialAxisComponent
  extends AxisComponent<RadialAxisState>
{
  @override
  RadialAxisState get originalState => RadialAxisState();

  @override
  List<RenderShape> getLine() {
    final coord = state.chart.state.coord as PolarCoordComponent;
    final position = state.position;
    final startRenderPoint = coord.convertPoint(Offset(position, 0));
    final endRenderPoint = coord.convertPoint(Offset(position, 1));
    return [LineRenderShape(
      x1: startRenderPoint.dx,
      y1: startRenderPoint.dy,
      x2: endRenderPoint.dx,
      y2: endRenderPoint.dy,
    )..mix(state.line.style)];
  }

  @override
  List<RenderShape> getTickLine() => [];

  @override
  List<RenderShape> getGrid() {
    final coord = state.chart.state.coord as PolarCoordComponent;
    final x = coord.center.dx;
    final y = coord.center.dy;
    final startAngle = coord.state.startAngle;
    final endAngle = coord.state.endAngle;
    final radius = coord.state.radius;
    final innerRadius = coord.state.innerRadius;
    final radiusLength = coord.radiusLength;
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
        final r = ((radius - innerRadius) * scaledTick + innerRadius) * radiusLength;
        rst.add(ArcRenderShape(
          x: x,
          y: y,
          r: r,
          startAngle: startAngle,
          endAngle: endAngle,
        )..mix(grid.style));
      }
    } else {
      for (var tick in ticks) {
        final scaledTick = scale.scale(tick);
        final r = ((radius - innerRadius) * scaledTick + innerRadius) * radiusLength;
        rst.add(ArcRenderShape(
          x: x,
          y: y,
          r: r,
          startAngle: startAngle,
          endAngle: endAngle,
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
          position,
          scaledTick,
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
          position,
          scaledTick,
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
    final bbox = label.bbox;
    final biasX = bbox.center.dx - label.state.x;
    final biasY = bbox.center.dy - label.state.y;
    label.translate(x: -biasX * 2, y: -biasY);
  }
}
