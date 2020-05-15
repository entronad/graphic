import 'dart:ui' show Rect, Offset;

import 'vector2.dart' show Vector2;

class SmoothDest {
  SmoothDest(this.cp1, this.cp2, this.p);

  final Offset cp1;
  final Offset cp2;
  // to point
  final Offset p;
}

List<Offset> _smoothBezier(
  List<Offset> points,
  num smooth,
  bool isLoop,
  [Rect constraint,]
) {
  final cps = <Offset>[];

  Vector2 prevVector;
  Vector2 nextVector;
  final hasConstraint = (constraint != null);
  Vector2 min;
  Vector2 max;
  Vector2 vector;
  if (hasConstraint) {
    min = Vector2(double.infinity, double.infinity);
    max = Vector2(double.negativeInfinity, double.negativeInfinity);

    for (final point in points) {
      vector = Vector2.fromOffset(point);
      Vector2.min(min, vector, min);
      Vector2.max(max, vector, max);
    }
    Vector2.min(min, Vector2.fromOffset(constraint.topLeft), min);
    Vector2.max(max, Vector2.fromOffset(constraint.bottomRight), min);
  }

  final len = points.length;
  for (var i = 0; i < len; i++) {
    vector = Vector2.fromOffset(points[i]);
    if (isLoop) {
      prevVector = Vector2.fromOffset(points[i > 0 ? i - 1 : len - 1]);
      nextVector = Vector2.fromOffset(points[(i + 1) % len]);
    } else {
      if (i == 0 || i == len -1) {
        cps.add(vector.toOffset());
        continue;
      } else {
        prevVector = Vector2.fromOffset(points[i - 1]);
        nextVector = Vector2.fromOffset(points[i + 1]);
      }
    }

    final v = (nextVector - prevVector) * smooth;
    var d0 = vector.distanceTo(prevVector);
    var d1 = vector.distanceTo(nextVector);

    final sum = d0 + d1;
    if (sum != 0) {
      d0 /= sum;
      d1 /= sum;
    }

    final v1 = v * (-d0);
    final v2 = v * d1;

    final cp0 = vector + v1;
    final cp1 = vector + v2;

    if (hasConstraint) {
      Vector2.max(cp0, min, cp0);
      Vector2.min(cp0, max, cp0);
      Vector2.max(cp1, min, cp1);
      Vector2.min(cp1, max, cp1);
    }

    cps.add(cp0.toOffset());
    cps.add(cp1.toOffset());
  }

  if (isLoop) {
    cps.add(cps.removeAt(0));
  }
  return cps;
}

List<SmoothDest> _catmullRom2bezier(
  List<Offset> pointList,
  bool z,
  [Rect constraint,]
) {
  final isLoop = z;

  final controlPointList = _smoothBezier(pointList, 0.4, isLoop, constraint);
  final len = pointList.length;
  final d1 = <SmoothDest>[];

  Offset cp1;
  Offset cp2;
  Offset p;

  for (var i = 0; i < len; i++) {
    cp1 = controlPointList[i * 2];
    cp2 = controlPointList[i * 2 + 1];
    p = pointList[i + 1];
    d1.add(SmoothDest(cp1, cp2, p));
  }

  if (isLoop) {
    cp1 = controlPointList[len];
    cp2 = controlPointList[len + 1];
    p = pointList[0];
    d1.add(SmoothDest(cp1, cp2, p));
  }
  return d1;
}

final smooth = _catmullRom2bezier;
