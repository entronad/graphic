import 'dart:ui' show Path;

import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;
import '../shape.dart' show Shape;

class Line extends Shape {
  Line(Cfg cfg) : super(cfg);

  @override
  Cfg get defaultCfg => super.defaultCfg
    ..type = 'line';
  
  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x1 = 0
    ..y1 = 0
    ..x2 = 0
    ..y2 = 0
    ..strokeWidth = 1;
  
  @override
  void createPath(Path path) {
    final x1 = attrs.x1;
    final y1 = attrs.y1;
    final x2 = attrs.x2;
    final y2 = attrs.y2;

    path.moveTo(x1, y1);
    path.lineTo(x2, y2);
  }
}
