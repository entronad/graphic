import 'dart:ui' show Offset;

import 'line.dart' show inLine;

bool inPolyline(
  List<Offset> points,
  double lineWidth,
  double x,
  double y,
  bool isClose,
) {
  final count = points.length;
  if (count < 2) {
    return false;
  }
  for (var i = 0; i < count - 1; i++) {
    final x1 = points[i].dx;
    final y1 = points[i].dy;
    final x2 = points[i + 1].dx;
    final y2 = points[i + 1].dy;

    if (inLine(x1, y1, x2, y2, lineWidth, x, y)) {
      return true;
    }
  }

  // 如果封闭，则计算起始点和结束点的边
  if (isClose) {
    final first = points[0];
    final last = points[count - 1];
    if (inLine(first.dx, first.dy, last.dx, last.dy, lineWidth, x, y)) {
      return true;
    }
  }

  return false;
}
