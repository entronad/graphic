import 'dart:ui' show
  Rect,
  Canvas,
  Size,
  Offset,
  Path,
  Paint;

import 'package:flutter/painting.dart' show TextPainter, TextDirection;

import 'shape.dart' show Shape;
import '../cfg.dart' show Cfg;
import '../attrs.dart' show Attrs;

class Text extends Shape {
  Text(Cfg cfg) : super(cfg) {
    attrs.applyToTextPainter(_textPainter);
    _textPainter.layout(maxWidth: attrs.width);
  }

  TextPainter _textPainter = TextPainter();

  @override
  Attrs get defaultAttrs => super.defaultAttrs
    ..x = 0
    ..y = 0
    ..width = double.infinity;

  @override
  void afterAttrsChange(Attrs targetAttrs) {
    super.afterAttrsChange(targetAttrs);
    attrs.applyToTextPainter(_textPainter);
    _textPainter.layout(maxWidth: attrs.width);
  }

  @override
  bool get isOnlyHitBBox => true;

  @override
  Rect calculateBBox() {
    final widthSign = _textPainter.textDirection == TextDirection.ltr ? 1 : -1;
    final width = widthSign * _textPainter.width;
    final height = _textPainter.height;
    return Rect.fromLTWH(attrs.x, attrs.y, width, height);
  }

  @override
  void paintShape(Canvas canvas, Size size, Path path, Paint paint) {
    _textPainter.paint(canvas, Offset(attrs.x, attrs.y));
  }

  @override
  Text clone() => Text(cfg.clone());
}
