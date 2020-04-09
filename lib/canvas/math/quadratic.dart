import 'dart:ui' show Offset, Rect;

import 'util.dart' show isNumberEqual, distance, getBBoxByArray;
import 'bezier.dart' as bezier show nearestPoint;

double _quadraticAt(List<double> arr) {
  assert(arr.length == 4);
  final p0 = arr[0];
  final p1 = arr[1];
  final p2 = arr[2];
  final t = arr[3];

  final onet = 1 - t;
  return onet * onet * p0 + 2 * t * onet * p1 + t * t * p2;
}

List<double> _extrema(double p0, double p1, double p2) {
  final a = p0 + p2 - 2 * p1;
  if (isNumberEqual(a, 0)) {
    return [0.5];
  }
  final rst = (p0 - p1) / a;
  if (rst <= 1 && rst >= 0) {
    return [rst];
  }
  return [];
}

List<List<double>> _divideQuadratic(double x1, double y1, double x2, double y2, double x3, double y3, double t) {
  final xt = _quadraticAt([x1, x2, x3, t]);
  final yt = _quadraticAt([y1, y2, y3, t]);

  final p1 = Offset(x1, y1);
  final p2 = Offset(x2, y2);
  final p3 = Offset(x3, y3);
  final controlPoint1 = Offset.lerp(p1, p2, t);
  final controlPoint2 = Offset.lerp(p2, p3, t);
  return [
    [x1, y1, controlPoint1.dx, controlPoint1.dy, xt, yt],
    [xt, yt, controlPoint2.dx, controlPoint2.dy, x3, y3],
  ];
}

double _quadraticLength(
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
  double iterationCount,
) {
  if (iterationCount == 0) {
    return (distance(x2 - x1, y2 - y1) + distance(x3 - x2, y3 - y2) + distance(x3 - x1, y3 - y1)) / 2;
  }
  final quadratics = _divideQuadratic(x1, y1, x2, y2, x3, y3, 0.5);
  final left = quadratics[0];
  final right = quadratics[1];
  left.add(iterationCount - 1);
  right.add(iterationCount - 1);
  return _quadraticLength(left[0], left[1], left[2], left[3], left[4], left[5], left[6])
    + _quadraticLength(right[0], right[1], right[2], right[3], right[4], right[5], right[6]);
}

Rect bbox(double x1, double y1, double x2, double y2, double x3, double y3) {
  final xExtremaList = _extrema(x1, x2, x3);
  final yExtremaList = _extrema(y1, y2, y3);
  final xExtrema = xExtremaList.isEmpty ? null : xExtremaList.first;
  final yExtrema = yExtremaList.isEmpty ? null : yExtremaList.first;
  final xArr = [x1, x3];
  final yArr = [y1, y3];
  if (xExtrema != null) {
    xArr.add(_quadraticAt([x1, x2, x3, xExtrema]));
  }
  if (yExtrema != null) {
    yArr.add(_quadraticAt([y1, y2, y3, yExtrema]));
  }
  return getBBoxByArray(xArr, yArr);
}

double length(double x1, double y1, double x2, double y2, double x3, double y3) =>
  _quadraticLength(x1, y1, x2, y2, x3, y3, 3);

Offset nearestPoint(double x1, double y1, double x2, double y2, double x3, double y3, double x0, double y0) =>
  bezier.nearestPoint([x1, x2, x3], [y1, y2, y3], x0, y0, _quadraticAt);

double pointDistance(double x1, double y1, double x2, double y2, double x3, double y3, double x0, double y0) {
  final point = nearestPoint(x1, y1, x2, y2, x3, y3, x0, y0);
  return distance(x0 - point.dx, y0 - point.dy);
}

const interpolationAt = _quadraticAt;

Offset pointAt(double x1, double y1, double x2, double y2, double x3, double y3, double t) =>
  Offset(_quadraticAt([x1, x2, x3, t]), _quadraticAt([y1, y2, y3, t]));

List<List<double>> divide(double x1, double y1, double x2, double y2, double x3, double y3, double t) =>
  _divideQuadratic(x1, y1, x2, y2, x3, y3, t);
