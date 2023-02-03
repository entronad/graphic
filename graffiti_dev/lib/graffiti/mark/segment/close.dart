import 'dart:ui';

import 'segment.dart';
import 'cubic.dart';

class CloseSegment extends Segment {
  CloseSegment({
    String? id,
  }) : super(
    id: id,
  );

  @override
  void drawPath(Path path) =>
    path.close();

  @override
  CloseSegment lerpFrom(covariant CloseSegment from, double t) => this;

  @override
  CubicSegment toCubic(Offset start) {
    throw UnsupportedError('Close segment should convert to line before to cubic.');
  }
}
