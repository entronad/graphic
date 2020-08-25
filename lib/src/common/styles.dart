import 'dart:ui';

import 'typed_map.dart';

class LineStyle with TypedMap {
  LineStyle({
    Color color,
    double strokeWidth,
    StrokeCap strokeCap,
    StrokeJoin strokeJoin,
    double strokeMiterLimit,
  }) {
    this['color'] = color;
    this['strokeWidth'] = strokeWidth;
    this['strokeCap'] = strokeCap;
    this['strokeJoin'] = strokeJoin;
    this['strokeMiterLimit'] = strokeMiterLimit;
  }
}
