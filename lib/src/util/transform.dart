import 'dart:ui';
import 'dart:math';

import 'package:vector_math/vector_math_64.dart';

final _zeroVector = Vector3.zero();

final _identityMatrix = Matrix4.identity();

Vector3 pointToVector(Offset point) =>
  Vector3(point.dx, point.dy, 0);

Offset vectorToPoint(Vector3 vector) =>
  Offset(vector.x, vector.y);

bool vectorIsZero(Vector3 vector) =>
  _zeroVector == vector;

bool matrixIsIdentity(Matrix4 matrix) =>
  _identityMatrix == matrix;

double vectorAngle(Vector3 fromVector, Vector3 toVector, [bool direction = false]) {
  final angle = fromVector.angleTo(toVector);
  final angleLargeThanPI = fromVector.x * toVector.y - fromVector.y * toVector.x >= 0;
  if (direction) {
    if (angleLargeThanPI) {
      return pi * 2 -angle;
    }

    return angle;
  }

  if (angleLargeThanPI) {
    return angle;
  }
  return pi * 2 - angle;
}
