import 'package:graphic/src/engine/render_shape/base.dart';
import 'package:graphic/src/engine/render_shape/line.dart';
import 'package:graphic/src/engine/render_shape/text.dart';

import 'base.dart';

class VerticalAxisState extends AxisState {}

class VerticalAxisComponent
  extends AxisComponent<VerticalAxisState>
{
  @override
  VerticalAxisState createState() => VerticalAxisState();

  @override
  List<RenderShape> getLine() {
    final region = state.chart.state.coord.state.region;
    final renderPosition = state.position * region.height;
    final x1 = region.left + renderPosition;
    final y1 = region.bottom;
    final x2 = region.left + renderPosition;
    final y2 = region.top;
    return [LineRenderShape(
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
    )..mix(state.line.style)];
  }

  @override
  List<RenderShape> getTickLine() {
    final region = state.chart.state.coord.state.region;
    final ticks = state.scale.state.ticks;
    final length = state.tickLine.length;

    final rst = <RenderShape>[];
    for (var tick in ticks) {
      final scaledTick = state.scale.scale(tick);
      final renderPosition = scaledTick * region.height;
      final x1 = region.left;
      final y1 = region.bottom - renderPosition;
      final x2 = region.left - length;
      final y2 = region.bottom - renderPosition;
      rst.add(LineRenderShape(
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
      )..mix(state.tickLine.style));
    }
    return rst;
  }

  @override
  List<RenderShape> getGrid() {
    final region = state.chart.state.coord.state.region;
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
        final renderPosition = scaledTick * region.height;
        final x1 = region.left;
        final y1 = region.bottom - renderPosition;
        final x2 = region.right;
        final y2 = region.bottom - renderPosition;
        rst.add(LineRenderShape(
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
        )..mix(grid.style));
      }
    } else {
      for (var tick in ticks) {
        final scaledTick = scale.scale(tick);
        final renderPosition = scaledTick * region.height;
        final x1 = region.left;
        final y1 = region.bottom - renderPosition;
        final x2 = region.right;
        final y2 = region.bottom - renderPosition;
        rst.add(LineRenderShape(
          x1: x1,
          y1: y1,
          x2: x2,
          y2: y2,
        )..mix(state.grid.style));
      }
    }
    return rst;
  }

  @override
  List<RenderShape> getLabel() {
    final region = state.chart.state.coord.state.region;
    final scale = state.scale;
    final ticks = scale.state.ticks;
    final count = ticks.length;
    final labelCallback = state.labelCallback;

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
        final renderPosition = scaledTick * region.height;
        final x = region.left;
        final y = region.bottom - renderPosition;
        rst.add(TextRenderShape(
          x: x,
          y: y,
          text: text,
          textStyle: label.style,
        ));
      }
    } else {
      for (var tick in ticks) {
        final scaledTick = scale.scale(tick);
        final text = scale.getText(tick);
        final renderPosition = scaledTick * region.height;
        final x = region.left;
        final y = region.bottom - renderPosition;
        rst.add(TextRenderShape(
          x: x,
          y: y,
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
