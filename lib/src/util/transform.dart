import 'dart:ui';
import 'dart:math';

import 'package:vector_math/vector_math_64.dart';

// In the vector calculation of this library, the points are treated as Vector3,
// and transforming matirx are treated as Matrix4:
//
// m11  m21  m31  x
// m12  m22  m32  y
// m13  m23  m33  z
// 0    0    0    1

/// The zero vector.
final _zeroVector = Vector3.zero();

/// The identity matrix.
final _identityMatrix = Matrix4.identity();

/// Converts a point to vector.
Vector3 pointToVector(Offset point) => Vector3(point.dx, point.dy, 0);

/// Converts a vector to point.
Offset vectorToPoint(Vector3 vector) => Offset(vector.x, vector.y);

/// Checks whether a vector is zero.
bool vectorIsZero(Vector3 vector) => _zeroVector == vector;

/// Checks whether a matrix is identity.
bool matrixIsIdentity(Matrix4 matrix) => _identityMatrix == matrix;

/// Gets the angle between two vector formed points.
double vectorAngle(Vector3 fromVector, Vector3 toVector,
    [bool direction = false]) {
  final angle = fromVector.angleTo(toVector);
  final angleLargeThanPI =
      fromVector.x * toVector.y - fromVector.y * toVector.x >= 0;
  if (direction) {
    if (angleLargeThanPI) {
      return pi * 2 - angle;
    }

    return angle;
  }

  if (angleLargeThanPI) {
    return angle;
  }
  return pi * 2 - angle;
}
