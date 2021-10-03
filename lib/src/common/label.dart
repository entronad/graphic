import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/graffiti/figure.dart';

import 'defaults.dart';

class LabelSyle {
  LabelSyle({
    TextStyle? style,
    this.offset,
    this.rotation,
  }) : this.style = style ?? Defaults.textStyle;

  /// Note that default color is white.
  TextStyle style;

  Offset? offset;

  double? rotation;

  @override
  bool operator ==(Object other) =>
    other is LabelSyle &&
    style == other.style &&
    offset == other.offset &&
    rotation == other.rotation;
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
  Offset anchor,
  double width,
  double height,
  Alignment align,
  Offset? offset,
) {
  var paintPoint = Offset(
    anchor.dx - (width / 2) + ((width / 2) * align.x),
    anchor.dy - (height / 2) + ((height / 2) * align.y),
  );
  if (offset != null) {
    paintPoint = paintPoint + offset;
  }
  return paintPoint;
}

Figure drawLabel(
  Label label,
  /// Where to paint the label, usually on top of the shape.
  Offset anchor,
  /// How the label bounds align the anchor.
  /// If Label is topLeft, it is [-1, -1].
  Alignment align,
) {
  final painter = TextPainter(
    text: TextSpan(text: label.text, style: label.style.style),
    textDirection: TextDirection.ltr,
  );
  painter.layout();
  
  var paintPoint = getPaintPoint(
    anchor,
    painter.width,
    painter.height,
    align,
    label.style.offset,
  );
  final rotation = label.style.rotation;
  if (rotation != null) {
    final labelCenter = Offset(
      paintPoint.dx + (painter.width / 2),
      paintPoint.dy + (painter.height / 2),
    );
    return RotatedTextFigure(
      painter,
      paintPoint,
      rotation,
      labelCenter,
    );
  } else {
    return TextFigure(painter, paintPoint);
  }
}
