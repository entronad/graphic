import 'dart:ui' show Offset, TextAlign;

import 'package:graphic/src/base.dart' show Base;
import 'package:graphic/src/engine/attrs.dart' show PaintCfg, Attrs;
import 'package:graphic/src/engine/util/vector2.dart' show Vector2;
import 'package:graphic/src/engine/container.dart' show Container;
import 'package:graphic/src/engine/cfg.dart' show Cfg;
import 'package:graphic/src/engine/shape.dart' show Shape;

import 'axis_cfg.dart' show AxisCfg, Tick, AxisType;

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
