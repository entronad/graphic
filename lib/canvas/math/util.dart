import 'dart:math' show sqrt, max, min;
import 'dart:ui' show Rect;

double distance(double dx, double dy) =>
  sqrt(dy * dy + dx * dx);

bool isNumberEqual(double v1, double v2) =>
  (v1 - v2).abs() < 0.001;

Rect getBBoxByArray(List<double> xArr, List<double> yArr) {
  final minX = xArr.reduce(min);
  final minY = yArr.reduce(min);
  final maxX = xArr.reduce(max);
  final maxY = yArr.reduce(max);
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}
