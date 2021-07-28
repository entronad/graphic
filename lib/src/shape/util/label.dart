import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/label.dart';

void paintLabel(
  Label label,
  /// Where to paint the label, usually on top of the shape.
  Offset anchor,
  /// How the anchor align the babel bounds.
  Alignment align,
  Canvas canvas,
) {
  final painter = TextPainter(
    text: TextSpan(text: label.text, style: label.style.style),
    textDirection: TextDirection.ltr,
  );
  painter.layout();
  
  var paintPoint = Offset(
    anchor.dx - ((painter.width / (1 - (-1)) * (align.x - (-1)))),
    anchor.dy - ((painter.height / (1 - (-1)) * (align.y - (-1)))),
  );
  final offset = label.style.offset;
  if (offset != null) {
    paintPoint = paintPoint + offset;
  }
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
