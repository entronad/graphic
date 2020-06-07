import 'dart:ui' show Offset;

import 'package:graphic/src/engine/util/vector2.dart' show Vector2;
import 'package:graphic/src/engine/attrs.dart' show PaintCfg, Attrs;
import 'package:graphic/src/engine/cfg.dart' show Cfg;

import 'abstract.dart' show Axis;
import 'axis_cfg.dart' show AxisCfg;

class LineAxis extends Axis {
  LineAxis(AxisCfg cfg) : super(cfg);

  @override
  Offset getOffsetPoint(double value) {
    final start = cfg.start;
    final end = cfg.end;
    return Offset(
      start.dx + (end.dx - start.dx) * value,
      start.dy + (end.dy - start.dy) * value,
    );
  }

  @override
  Vector2 getAxisVector(Offset point) {
    final start = cfg.start;
    final end = cfg.end;
    return Vector2(end.dx - start.dx, end.dy - start.dy);
  }

  @override
  void drawLine(PaintCfg lineCfg) {
    final start = cfg.start;
    final end = cfg.end;
    final container = getContainer(lineCfg.top);
    container.addShape(Cfg(
      type: 'line',
      attrs: Attrs(
        x1: start.dx,
        y1: start.dy,
        x2: end.dx,
        y2: end.dy,
      ).mix(lineCfg),
    ));
  }
}
