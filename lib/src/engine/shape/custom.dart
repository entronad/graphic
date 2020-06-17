import 'dart:ui';

import '../cfg.dart';
import '../attrs.dart';
import '../shape.dart';

class Custom extends Shape {
  Custom(Cfg cfg) : super(cfg);

  @override
  Cfg get defaultCfg => super.defaultCfg
    ..type = 'custom';
  
  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..path = Path();
  
  @override
  void drawInner(Canvas canvas, Size size) {
    canvas.drawPath(attrs.path, paintObj);
  }

  @override
  Rect calculateBox() {
    final bbox = attrs.path.getBounds();
    if (paintingStyle == PaintingStyle.stroke) {
      return bbox.inflate(attrs.strokeWidth / 2);
    }
    return bbox;
  }
}
