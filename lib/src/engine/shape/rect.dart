import 'dart:ui' show Path, RRect, Radius;

import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;
import '../shape.dart' show Shape;

class Rect extends Shape {
  Rect(Cfg cfg) : super(cfg);

  @override
  Cfg get defaultCfg => super.defaultCfg
    ..type = 'rect';
  
  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x = 0
    ..y = 0
    ..r = 0
    ..width = 0
    ..height = 0
    ..strokeWidth = 0;
  
  @override
  void createPath(Path path) {
    final left = attrs.x;
    final top = attrs.y;
    final width = attrs.width;
    final height = attrs.height;
    final r = attrs.r;

    final rrect = RRect.fromLTRBR(
      left,
      top,
      left + width,
      top + height,
      Radius.circular(r)
    );
    path.addRRect(rrect);
  }
}
