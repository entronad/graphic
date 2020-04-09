import 'dart:ui' show Offset;

import 'util.dart' show distance;

double length(List<Offset> points) {
  if (points.length < 2) {
    return 0;
  }
  var totalLength = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final from = points[i];
    final to = points[i + 1];
    totalLength += distance(to.dx - from.dx, to.dy - from.dy);
  }
  return totalLength;
}
