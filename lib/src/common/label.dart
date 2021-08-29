import 'dart:ui';

import 'package:flutter/painting.dart';

class LabelSyle {
  const LabelSyle({
    this.style = const TextStyle(),
    this.offset,
    this.rotation,
  });

  /// Note that default color is white.
  final TextStyle style;

  final Offset? offset;

  final double? rotation;

  @override
  bool operator ==(Object other) =>
    other is LabelSyle &&
    style == other.style &&
    offset == other.offset &&
    rotation == other.rotation;
}

class Label {
  Label(this.text, this.style);

  final String text;

  final LabelSyle style;

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
    anchor.dx + ((width / (1 - (-1)) * (align.x - (-1)))),
    anchor.dy + ((height / (1 - (-1)) * (align.y - (-1)))),
  );
  if (offset != null) {
    paintPoint = paintPoint + offset;
  }
  return paintPoint;
}

void paintLabel(
  Label label,
  /// Where to paint the label, usually on top of the shape.
  Offset anchor,
  /// How the label bounds align the anchor.
  /// If Label is topLeft, it is [-1, -1].
  Alignment align,
  Canvas canvas,
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
    canvas.save();

    final labelCenter = Offset(
      paintPoint.dx + (painter.width / 2),
      paintPoint.dy + (painter.height / 2),
    );
    canvas.translate(labelCenter.dx, labelCenter.dy);
    canvas.rotate(rotation);
    canvas.translate(-labelCenter.dx, -labelCenter.dy);

    painter.paint(canvas, paintPoint);

    canvas.restore();
  } else {
    painter.paint(canvas, paintPoint);
  }
}
