import 'dart:ui' show
  Path,
  Canvas,
  Rect,
  PaintingStyle,
  Size;

import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;
import '../shape.dart' show Shape;

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
