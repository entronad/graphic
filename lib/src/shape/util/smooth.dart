import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';
import 'package:graphic/src/util/transform.dart';

// Produces a cubic Catmull–Rom spline

class BezierSegment {
  BezierSegment(this.cp1, this.cp2, this.p);

  final Offset cp1;
  final Offset cp2;
  final Offset p;    // to point
}

List<Offset> _getControlPoints(
  List<Offset> points,
  double ratio,
  bool isLoop,
  bool hasConstraint,
  [Rect? constraint,]
) {
  final vectors = points.map((point) =>pointToVector(point)).toList();

  final cps = <Offset>[];
  Vector3 prevVector;
  Vector3 nextVector;
  Vector3? min;
  Vector3? max;

  // Real constraint box is:
  // bbox of points, if constraint is null
  // the bigger one of constraint and bbox of points, if constraint is not null
  if (hasConstraint) {
    min = Vector3(double.infinity, double.infinity, 0);
    max = Vector3(double.negativeInfinity, double.negativeInfinity, 0);

    for (var vector in vectors) {
      Vector3.min(min, vector, min);
      Vector3.max(max, vector, max);
    }
    if (constraint != null) {
      Vector3.min(min,pointToVector(constraint.topLeft), min);
      Vector3.max(max,pointToVector(constraint.bottomRight), max);
    }
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
      Vector3.max(cp0, min!, cp0);
      Vector3.min(cp0, max!, cp0);
      Vector3.max(cp1, min, cp1);
      Vector3.min(cp1, max, cp1);
    }

    cps.add(vectorToPoint(cp0));
    cps.add(vectorToPoint(cp1));
  }

  if (isLoop) {
    cps.add(cps.removeAt(0));
  }
  return cps;
}

List<BezierSegment> smooth(
  List<Offset> points,
  bool isLoop,
  bool hasConstraint,
  [Rect? constraint,]
) {
  // Alpha is 0.5, as proposed by Yuksel et al.
  // Thus is called a centripetal spline: https://en.wikipedia.org/wiki/Centripetal_Catmull%E2%80%93Rom_spline
  final controlPointList = _getControlPoints(points, 0.5, isLoop, hasConstraint, constraint);
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
