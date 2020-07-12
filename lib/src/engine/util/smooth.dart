import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

class BezierSegment {
  BezierSegment(this.cp1, this.cp2, this.p);

  final Offset cp1;
  final Offset cp2;
  // to point
  final Offset p;
}

Vector2 _pointToVector2(Offset point) =>
  Vector2(point.dx, point.dy);

Offset _vector2ToPoint(Vector2 vector) =>
  Offset(vector.x, vector.y);

List<Offset> _getControlPoints(
  List<Offset> points,
  double ratio,
  bool isLoop,
  [Rect constraint,]
) {
  final hasConstraint = (constraint != null);
  final vectors = points.map((point) => _pointToVector2(point)).toList();

  final cps = <Offset>[];
  Vector2 prevVector;
  Vector2 nextVector;
  Vector2 min;
  Vector2 max;

  // real constraint box is the bigger one of constraint and bbox of points
  if (hasConstraint) {
    min = Vector2(double.infinity, double.infinity);
    max = Vector2(double.negativeInfinity, double.negativeInfinity);

    for (var vector in vectors) {
      Vector2.min(min, vector, min);
      Vector2.max(max, vector, max);
    }
    Vector2.min(min, _pointToVector2(constraint.topLeft), min);
    Vector2.max(max, _pointToVector2(constraint.bottomRight), max);
  }

  final len = points.length;
  for (var i = 0; i < len; i++) {
    final vector = vectors[i];
    if (isLoop) {
      prevVector = vectors[i >= 1 ? i - 1 : len - 1];
      nextVector = vectors[(i + 1) % len];
    } else {
      if (i == 0 || i == len -1) {
        cps.add(points[i]);
        continue;
      } else {
        prevVector = vectors[i - 1];
        nextVector = vectors[i + 1];
      }
    }

    final v = (nextVector - prevVector) * ratio;
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

    cps.add(_vector2ToPoint(cp0));
    cps.add(_vector2ToPoint(cp1));
  }

  if (isLoop) {
    cps.add(cps.removeAt(0));
  }
  return cps;
}

List<BezierSegment> smooth(
  List<Offset> points,
  bool isLoop,
  [Rect constraint,]
) {
  final controlPointList = _getControlPoints(points, 0.4, isLoop, constraint);
  final len = points.length;
  final rst = <BezierSegment>[];

  Offset cp1;
  Offset cp2;
  Offset p;

  for (var i = 0; i < len - 1; i++) {
    cp1 = controlPointList[i * 2];
    cp2 = controlPointList[i * 2 + 1];
    p = points[i + 1];
    rst.add(BezierSegment(cp1, cp2, p));
  }

  if (isLoop) {
    cp1 = controlPointList[len];
    cp2 = controlPointList[len + 1];
    p = points[0];
    rst.add(BezierSegment(cp1, cp2, p));
  }

  return rst;
}
