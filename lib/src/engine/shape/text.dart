import 'dart:ui';

import 'package:flutter/painting.dart';
import '../cfg.dart';
import '../attrs.dart';
import '../shape.dart';

class Text extends Shape {
  Text(Cfg cfg) : super(cfg) {
    attrs.applyToTextPainter(_textPainter);
    _textPainter.layout(maxWidth: attrs.width);
  }

  TextPainter _textPainter = TextPainter();

  @override
  Cfg get defaultCfg => super.defaultCfg
    ..type = 'text';
  
  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x = 0
    ..y = 0
    ..width = double.infinity;
  
  @override
  void afterAttrsSet() {
    super.afterAttrsSet();
    attrs.applyToTextPainter(_textPainter);
    _textPainter.layout(maxWidth: attrs.width);
  }

  @override
  void drawInner(Canvas canvas, Size size) {
    final x = attrs.x;
    final y = attrs.y;

    _textPainter.paint(canvas, Offset(x, y));
  }

  @override
  Rect calculateBox() {
    final widthSign = _textPainter.textDirection == TextDirection.ltr ? 1 : -1;
    final width = widthSign * _textPainter.width;
    final height = _textPainter.height;
    return Rect.fromLTWH(attrs.x, attrs.y, width, height);
  }
}
