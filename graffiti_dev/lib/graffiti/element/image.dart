import 'dart:ui';

import 'package:flutter/painting.dart';

import 'element.dart';

// TODO: Image loading functions.

class ImageStyle extends BlockStyle {
  ImageStyle({
    this.blendMode,

    Offset? offset,
    double? rotation,
    Alignment? align,
  }) : super(
    offset: offset,
    rotation: rotation,
    align: align,
  );

  final BlendMode? blendMode;

  @override
  ImageStyle lerpFrom(covariant ImageStyle from, double t) => ImageStyle(
    blendMode: blendMode,
    offset: Offset.lerp(from.offset, offset, t),
    rotation: lerpDouble(from.rotation, rotation, t),
    align: Alignment.lerp(from.align, align, t),
  );
}

final _defaultImageStyle = ImageStyle();

class ImageElement extends BlockElement<ImageStyle> {
  ImageElement({
    required this.image,

    required Offset anchor,
    Alignment? defaultAlign,
    ImageStyle? style,
  }) : super(
    anchor: anchor,
    defaultAlign: defaultAlign ?? Alignment.center,
    style: style ?? _defaultImageStyle,
  ) {
    // TODO: Image width height pixel ratio
    paintPoint = getPaintPoint(rotationAxis!, image.width.toDouble(), image.height.toDouble(), this.style.align ?? this.defaultAlign);
  }

  final Image image;
  
  @override
  void draw(Canvas canvas) =>
    canvas.drawImage(image, paintPoint, Paint());
  
  @override
  ImageElement lerpFrom(covariant ImageElement from, double t) => ImageElement(
    image: image,
    anchor: Offset.lerp(from.anchor, anchor, t)!,
    defaultAlign: Alignment.lerp(from.defaultAlign, defaultAlign, t)!,
    style: style.lerpFrom(from.style, t),
  );
}
