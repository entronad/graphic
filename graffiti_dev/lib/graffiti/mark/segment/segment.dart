import 'dart:ui';

import 'cubic.dart';

abstract class Segment {
  Segment({
    this.id,
  });

  final String? id;

  void drawPath(Path path);

  Segment lerpFrom(covariant Segment from, double t);

  CubicSegment toCubic(Offset start);
}
