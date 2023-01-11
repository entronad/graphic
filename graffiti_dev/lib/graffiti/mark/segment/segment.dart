import 'dart:ui';

abstract class Segment {
  Segment({
    required this.relative,
  });

  final bool relative;

  void absoluteDrawPath(Path path);

  void relativeDrawPath(Path path);

  void drawPath(Path path) => relative
    ? relativeDrawPath(path)
    : absoluteDrawPath(path);
}
