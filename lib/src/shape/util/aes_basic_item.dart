import 'dart:ui';

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/shape/util/gradient.dart';

/// Aesthetic the basic item with path provided.
/// Size is considered in path.
/// It dosen't include label.
List<Figure> drawBasicItem(
  Path path,
  Aes aes,
  bool hollow,
  double strokeWidth,
) {
  final rst = <Figure>[];

  final style = Paint();
  if (aes.gradient != null) {
    style.shader = toUIGradient(
      aes.gradient!,
      path.getBounds(),
    );
  } else {
    style.color = aes.color!;
  }
  style.style = hollow
    ? PaintingStyle.stroke
    : PaintingStyle.fill;
  style.strokeWidth = strokeWidth;
  
  if (aes.elevation != null) {
    Color? shadowColor;
    if (aes.gradient != null) {
      shadowColor = getShadowColor(aes.gradient!);
    } else {
      shadowColor = aes.color!;
    }
    rst.add(ShadowFigure(
      path,
      shadowColor,
      aes.elevation!,
    ));
  }

  rst.add(PathFigure(path, style));

  return rst;
}
