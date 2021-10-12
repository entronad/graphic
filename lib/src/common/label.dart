import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/graffiti/figure.dart';

import 'defaults.dart';

class LabelSyle {
  LabelSyle({
    TextStyle? style,
    this.offset,
    this.rotation,
    this.align,
  }) : this.style = style ?? Defaults.textStyle;

  /// Note that default color is white.
  TextStyle style;

  Offset? offset;

  double? rotation;

  Alignment? align;

  @override
  bool operator ==(Object other) =>
    other is LabelSyle &&
    style == other.style &&
    offset == other.offset &&
    rotation == other.rotation &&
    align == other.align;
}

class Label {
  Label(
    this.text,
    [LabelSyle? style,]
  ) : this.style = style ?? LabelSyle();

  String text;

  LabelSyle style;

  @override
  bool operator ==(Object other) =>
    other is Label &&
    text == other.text &&
    style == other.style;
}

Offset getPaintPoint(
  Offset axis,
  double width,
  double height,
  Alignment align,
) => Offset(
  axis.dx - (width / 2) + ((width / 2) * align.x),
  axis.dy - (height / 2) + ((height / 2) * align.y),
);

Figure drawLabel(
  Label label,
  /// Where to paint the label, usually on top of the shape.
  Offset anchor,
  /// How the label bounds align the anchor.
  /// If Label is topLeft, it is [-1, -1].
  Alignment defaultAlign,
) {
  final painter = TextPainter(
    text: TextSpan(text: label.text, style: label.style.style),
    textDirection: TextDirection.ltr,
  );
  painter.layout();
  
  final axis = label.style.offset == null
    ? anchor
    : anchor + label.style.offset!;
  
  final align = label.style.align ?? defaultAlign;

  var paintPoint = getPaintPoint(
    axis,
    painter.width,
    painter.height,
    align,
  );
  final rotation = label.style.rotation;
  if (rotation != null) {
    return RotatedTextFigure(
      painter,
      paintPoint,
      rotation,
      axis,
    );
  } else {
    return TextFigure(painter, paintPoint);
  }
}
