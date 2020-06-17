import 'dart:math';
import 'dart:ui';

import 'package:graphic/src/engine/util/vector2.dart';
import 'package:graphic/src/engine/attrs.dart';
import 'package:graphic/src/engine/cfg.dart';

import 'base.dart';

class CircleAxis extends Axis {
  CircleAxis(AxisCfg cfg) : super(cfg);

  @override
  AxisCfg get defaultCfg => super.defaultCfg
    ..type = AxisType.circle
    ..startAngle = -pi / 2
    ..endAngle = pi * 3 / 2;
  
  @override
  Offset getOffsetPoint(double value) {
    final startAngle = cfg.startAngle;
    final endAngle = cfg.endAngle;
    final angle = startAngle + (endAngle - startAngle) * value;
    return _getCirclePoint(angle);
  }

  Offset _getCirclePoint(double angle, [double radius]) {
    final center = cfg.center;
    radius = radius ?? cfg.radius;
    return Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );
  }

  @override
  Vector2 getAxisVector(Offset point) {
    final center = cfg.center;
    final factor = cfg.offsetFactor;
    return Vector2((point.dy - center.dy) * factor, (point.dx - center.dx) * -1 * factor);
  }

  @override
  void drawLine(PaintCfg lineCfg) {
    final center = cfg.center;
    final radius = cfg.radius;
    final startAngle = cfg.startAngle;
    final endAngle = cfg.endAngle;
    final container = getContainer(lineCfg.top);
    container.addShape(Cfg(
      type: 'arc',
      attrs: Attrs(
        x: center.dx,
        y: center.dy,
        r: radius,
        startAngle: startAngle,
        endAngle: endAngle,
      ).mix(lineCfg),
    ));
  }
}
