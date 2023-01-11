import 'dart:ui';

import 'segment.dart';

class CloseSegment extends Segment {
  CloseSegment() : super(
    relative: false,
  );

  @override
  void drawPath(Path path) =>
    path.close();

  @override
  void absoluteDrawPath(Path path) {}

  @override
  void relativeDrawPath(Path path) {}
}
