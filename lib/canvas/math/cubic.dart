import 'dart:ui' show Offset, Rect;
import 'dart:math' show sqrt;

import 'util.dart' show isNumberEqual, distance, getBBoxByArray;
import 'bezier.dart' as bezier show nearestPoint, snapLength;

double _cubicAt(List<double> arr) {
  assert(arr.length == 5);
  final p0 = arr[0];
  final p1 = arr[1];
  final p2 = arr[2];
  final p3 = arr[3];
  final t = arr[4];

  final onet = 1 - t;
  return onet * onet * onet * p0 + 3 * p1 * t * onet * onet + 3 * p2 * t * t * onet + p3 * t * t * t;
}

List<double> _extrema(double p0, double p1, double p2, double p3) {
  final a = -3 * p0 + 9 * p1 - 9 * p2 + 3 * p3;
  final b = 6 * p0 - 12 * p1 + 6 * p2;
  final c = 3 * p1 - 3 * p0;
  final extremas = <double>[];
  double t1;
  double t2;
  double discSqrt;

  if (isNumberEqual(a, 0)) {
    if (!isNumberEqual(b, 0)) {
      t1 = -c / b;
      if (t1 >= 0 && t1 <= 1) {
        extremas.add(t1);
      }
    }
  } else {
    final disc = b * b - 4 * a * c;
    if (isNumberEqual(disc, 0)) {
      extremas.add(-b / (2 * a));
    } else if (disc > 0) {
      discSqrt = sqrt(disc);
      t1 = (-b + discSqrt) / (2 * a);
      t2 = (-b - discSqrt) / (2 * a);
      if (t1 >= 0 && t1 <= 1) {
        extremas.add(t1);
      }
      if (t2 >= 0 && t2 <= 1) {
        extremas.add(t2);
      }
    }
  }
  return extremas;
}

List<List<double>> _divideCubic(
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
  double x4,
  double y4,
  double t,
) {
  final xt = _cubicAt([x1, x2, x3, x4, t]);
  final yt = _cubicAt([y1, y2, y3, y4, t]);
  final p1 = Offset(x1, y1);
  final p2 = Offset(x2, y2);
  final p3 = Offset(x3, y3);
  final p4 = Offset(x4, y4);
  final c1 = Offset.lerp(p1, p2, t);
  final c2 = Offset.lerp(p2, p3, t);
  final c3 = Offset.lerp(p3, p4, t);
  final c12 = Offset.lerp(c1, c2, t);
  final c23 = Offset.lerp(c2, c3, t);

  return [
    [x1, y1, c1.dx, c1.dy, c12.dx, c12.dy, xt, yt],
    [xt, yt, c23.dx, c23.dy, c3.dx, c3.dy, x4, y4],
  ];
}

double _cubicLength(
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
  double x4,
  double y4,
  double iterationCount,
) {
  if (iterationCount == 0) {
    return bezier.snapLength([x1, x2, x3, x4], [y1, y2, y3, y4]);
  }
  final cubics = _divideCubic(x1, y1, x2, y2, x3, y3, x4, y4, 0.5);
  final left = cubics[0];
  final right = cubics[1];
  left.add(iterationCount - 1);
  right.add(iterationCount - 1);
  return _cubicLength(left[0], left[1], left[2], left[3], left[4], left[5], left[6], left[7], left[8])
    + _cubicLength(right[0], right[1], right[2], right[3], right[4], right[5], right[6], right[7], right[8]);
}

Rect bbox(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) {
  final xArr = [x1, x4];
  final yArr = [y1, y4];
  final xExtrema = _extrema(x1, x2, x3, x4);
  final yExtrema = _extrema(y1, y2, y3, y4);
  for (var i = 0; i < xExtrema.length; i++) {
      xArr.add(_cubicAt([x1, x2, x3, x4, xExtrema[i]]));
    }
    for (var i = 0; i < yExtrema.length; i++) {
      yArr.add(_cubicAt([y1, y2, y3, y4, yExtrema[i]]));
    }
    return getBBoxByArray(xArr, yArr);
}

double length(double x1, double y1, double x2, double y2, double x3, double y3, double x4, double y4) =>
  _cubicLength(x1, y1, x2, y2, x3, y3, x4, y4, 3);

Offset nearestPoint(
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
  double x4,
  double y4,
  double x0,
  double y0,
) => bezier.nearestPoint([x1, x2, x3, x4], [y1, y2, y3, y4], x0, y0, _cubicAt);

double pointDistance(
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
  double x4,
  double y4,
  double x0,
  double y0,
) {
  final point = nearestPoint(x1, y1, x2, y2, x3, y3, x4, y4, x0, y0);
  return distance(x0 - point.dx, y0 - point.dy);
}

const interpolationAt = _cubicAt;

Offset pointAt(
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
  double x4,
  double y4,
  double t,
) =>
  Offset(_cubicAt([x1, x2, x3, x4, t]), _cubicAt([y1, y2, y3, x4, t]));

List<List<double>> divide(
  double x1,
  double y1,
  double x2,
  double y2,
  double x3,
  double y3,
  double x4,
  double y4,
  double t,
) => _divideCubic(x1, y1, x2, y2, x3, y3, x4, y4, t);
