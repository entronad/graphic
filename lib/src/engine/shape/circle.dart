import 'dart:ui' show Path, Rect, Offset;

import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;
import '../shape.dart' show Shape;

class Circle extends Shape {
  Circle(Cfg cfg) : super(cfg);

  @override
  Cfg get defaultCfg => super.defaultCfg
    ..type = 'circle';
  
  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x = 0
    ..y = 0
    ..r = 0
    ..strokeWidth = 0;
  
  @override
  void createPath(Path path) {
    final x = attrs.x;
    final y = attrs.y;
    final r = attrs.r;

    path.addOval(Rect.fromCircle(center: Offset(x, y), radius: r));
  }
}
