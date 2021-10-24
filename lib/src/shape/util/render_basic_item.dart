import 'dart:ui';

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/shape/util/gradient.dart';

/// Renders a basic element item.
/// 
/// This is a util function for implementing [Shape.renderGroup] and [Shape.renderItem].
/// The [path] should be calculated before it and label is not rendered in it.
/// 
/// See also
/// 
/// - [Shape.renderGroup] and [Shape.renderItem], where this function is usually used.
/// - [renderLabel], which renders an item label.
List<Figure> renderBasicItem(
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
  
  if (aes.elevation != null && aes.elevation != 0) {
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
