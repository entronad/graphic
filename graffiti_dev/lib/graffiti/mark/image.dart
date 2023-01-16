import 'dart:ui';

import 'package:flutter/painting.dart';

import 'mark.dart';

// TODO: Image loading functions.

class ImageMark extends BoxMark<BoxStyle> {
  ImageMark({
    required this.image,

    required Offset anchor,
    required Alignment defaultAlign,
    required BoxStyle style,
  }) : super(
    anchor: anchor,
    defaultAlign: defaultAlign,
    style: style,
  ) {
    paintPoint = getPaintPoint(rotationAxis!, image.width.toDouble(), image.height.toDouble(), style.align ?? defaultAlign); // TODO: Image width height pixel ratio.
  }

  final Image image;
  
  @override
  void draw(Canvas canvas) =>
    canvas.drawImage(image, paintPoint, Paint());
}
