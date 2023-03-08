import 'dart:ui';

import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/graffiti/figure.dart';
import 'package:graphic/src/shape/util/gradient.dart';

import '../shape.dart';

/// Renders a basic mark item.
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
  Attributes attributes,
  bool hollow,
  double strokeWidth, [
  Rect? gradientBounds,
]) {
  final rst = <Figure>[];

  final style = Paint();
  if (attributes.gradient != null) {
    style.shader = toUIGradient(
      attributes.gradient!,
      gradientBounds == null
          ? path.getBounds()
          : path.getBounds().intersect(gradientBounds),
    );
  } else {
    style.color = attributes.color!;
  }
  style.style = hollow ? PaintingStyle.stroke : PaintingStyle.fill;
  style.strokeWidth = strokeWidth;

  if (attributes.elevation != null && attributes.elevation != 0) {
    Color? shadowColor;
    if (attributes.gradient != null) {
      shadowColor = getShadowColor(attributes.gradient!);
    } else {
      shadowColor = attributes.color!;
    }
    rst.add(ShadowFigure(
      path,
      shadowColor,
      attributes.elevation!,
    ));
  }

  rst.add(PathFigure(path, style));

  return rst;
}
