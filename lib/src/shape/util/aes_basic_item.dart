import 'dart:ui';

import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/shape/util/gradient.dart';

/// Aesthetic the basic item with path provided.
/// Size is considered in path.
/// It dosen't include label.
void aesBasicItem(
  Path path,
  Aes aes,
  bool hollow,
  double strokeWidth,
  Canvas canvas,
) {
  final style = Paint();
  Color? shadowColor;
  if (aes.gradient != null) {
    style.shader = toUIGradient(
      aes.gradient!,
      path.getBounds(),
    );
    shadowColor = getShadowColor(aes.gradient!);
  } else {
    style.color = aes.color!;
    shadowColor = aes.color!;
  }
  style.style = hollow
    ? PaintingStyle.stroke
    : PaintingStyle.fill;
  style.strokeWidth = strokeWidth;
  
  canvas.drawPath(path, style);
  if (aes.elevation != null) {
    canvas.drawShadow(
      path,
      shadowColor,
      aes.elevation!,
      true,
    );
  }
}
