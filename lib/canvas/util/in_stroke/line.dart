import 'dart:math' show max, min;

import '../../math/line.dart' show pointToLine;

bool inLine(
  double x1,
  double y1,
  double x2,
  double y2,
  double lineWidth,
  double x,
  double y,
) {
  final minX = min(x1, x2);
  final maxX = max(x1, x2);
  final minY = min(y1, y2);
  final maxY = max(y1, y2);
  final halfWidth = lineWidth / 2;
  if (!(x >= minX - halfWidth && x <= maxX + halfWidth && y >= minY - halfWidth && y <= maxY + halfWidth)) {
    return false;
  }
  return pointToLine(x1, y1, x2, y2, x, y) <= lineWidth / 2;
}
