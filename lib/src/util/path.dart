import 'dart:math';
import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:graphic/src/util/math.dart';

import 'transform.dart';

/// Some useful path functions for rendering.
abstract class Paths {
  /// A line path function.
  ///
  /// This functions can either return a new path or add to existing [path].
  static Path line({
    required Offset from,
    required Offset to,
    Path? path,
  }) =>
      (path ?? Path())
        ..moveTo(from.dx, from.dy)
        ..lineTo(to.dx, to.dy);

  /// A polyline path function.
  ///
  /// This functions can either return a new path or add to existing [path].
  static Path polyline({
    required List<Offset> points,
    required bool smooth,
    Path? path,
  }) {
    path = path ?? Path();

    path.moveTo(points[0].dx, points[0].dy);
    if (smooth) {
      final segments = getBezierSegments(points, false, true);
      for (var s in segments) {
        path.cubicTo(s.cp1.dx, s.cp1.dy, s.cp2.dx, s.cp2.dy, s.p.dx, s.p.dy);
      }
    } else {
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    return path;
  }

  /// A dash line path function.
  ///
  /// It is drawn from the segments of [source]. Passing a [source] that is an empty
  /// path will return an empty path. Dash intervals are controled by the [dashArray].
  /// The [dashOffset] specifies an initial starting point for the dashing.
  ///
  /// This functions can either return a new path or add to existing [path].
  static Path dashLine({
    required Path source,
    required List<double> dashArray,
    DashOffset? dashOffset,
    Path? path,
  }) =>
      (path ?? Path())
        ..addPath(dashPath(source, dashArray: CircularIntervalList(dashArray), dashOffset: dashOffset), Offset.zero);

  /// A circle path function.
  ///
  /// This functions can either return a new path or add to existing [path].
  static Path circle({
    required Offset center,
    required double radius,
    Path? path,
  }) =>
      (path ?? Path())
        ..addOval(Rect.fromCircle(center: center, radius: radius));

  /// A sector path function.
  ///
  /// This functions can either return a new path or add to existing [path].
  static Path sector({
    required Offset center,
    required double r,
    required double r0,
    required double startAngle,
    required double endAngle,
    required bool clockwise,
    Path? path,
  }) {
    path = path ?? Path();

    final sweepAngle =
        clockwise ? endAngle - startAngle : startAngle - endAngle;

    // The canvas can not fill a ring, so it is devided to two semi rings
    if (sweepAngle.abs().equalTo(pi * 2)) {
      sector(
        center: center,
        r: r,
        r0: r0,
        startAngle: 0,
        endAngle: pi,
        clockwise: true,
        path: path,
      );
      sector(
        center: center,
        r: r,
        r0: r0,
        startAngle: pi,
        endAngle: pi * 2,
        clockwise: true,
        path: path,
      );
      return path;
    }

    path.moveTo(
        cos(startAngle) * r + center.dx, sin(startAngle) * r + center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: r),
      startAngle,
      sweepAngle,
      false,
    );
    path.lineTo(cos(endAngle) * r0 + center.dx, sin(endAngle) * r0 + center.dy);
    if (r0 != 0) {
      path.arcTo(
        Rect.fromCircle(center: center, radius: r0),
        endAngle,
        -sweepAngle,
        false,
      );
    }
    path.close();

    return path;
  }

  /// A sector with corner radiuses.
  ///
  /// This functions can either return a new path or add to existing [path].
  ///
  /// For a sector, [Radius.x] is circular, [Radius.y] is radial, top is outer side,
  /// bottom is inner side, left is anticlockwise, right is clockwise.
  static Path rsector({
    required Offset center,
    required double r,
    required double r0,
    required double startAngle,
    required double endAngle,
    required bool clockwise,
    required Radius topLeft,
    required Radius topRight,
    required Radius bottomRight,
    required Radius bottomLeft,
    Path? path,
  }) {
    path = path ?? Path();

    // The canvas can not fill a ring, so it is devided to two semi rings
    if ((endAngle - startAngle).abs().equalTo(pi * 2)) {
      sector(
        center: center,
        r: r,
        r0: r0,
        startAngle: 0,
        endAngle: pi,
        clockwise: true,
        path: path,
      );
      sector(
        center: center,
        r: r,
        r0: r0,
        startAngle: pi,
        endAngle: pi * 2,
        clockwise: true,
        path: path,
      );
      return path;
    }

    double arcStart;
    double arcEnd;
    double arcSweep;

    // Calculates the top angles.

    arcStart =
        clockwise ? startAngle + (topLeft.x / r) : startAngle - (topLeft.x / r);
    arcEnd =
        clockwise ? endAngle - (topRight.x / r) : endAngle + (topRight.x / r);
    arcSweep = clockwise ? arcEnd - arcStart : arcStart - arcEnd;

    // The top left corner.

    path.moveTo(
      cos(startAngle) * (r - topLeft.y) + center.dx,
      sin(startAngle) * (r - topLeft.y) + center.dy,
    );
    path.quadraticBezierTo(
      cos(startAngle) * r + center.dx,
      sin(startAngle) * r + center.dy,
      cos(arcStart) * r + center.dx,
      sin(arcStart) * r + center.dy,
    );

    // The top arc.

    path.arcTo(
      Rect.fromCircle(center: center, radius: r),
      arcStart,
      arcSweep,
      false,
    );

    // The top right corner.

    path.quadraticBezierTo(
      cos(endAngle) * r + center.dx,
      sin(endAngle) * r + center.dy,
      cos(endAngle) * (r - topRight.y) + center.dx,
      sin(endAngle) * (r - topRight.y) + center.dy,
    );
    path.lineTo(
      cos(endAngle) * (r0 + bottomRight.y) + center.dx,
      sin(endAngle) * (r0 + bottomRight.y) + center.dy,
    );

    if (r0 != 0) {
      // Calculates the bottom angles.

      arcStart = clockwise
          ? startAngle + (bottomLeft.x / r)
          : startAngle - (bottomLeft.x / r);
      arcEnd = clockwise
          ? endAngle - (bottomRight.x / r)
          : endAngle + (bottomRight.x / r);
      arcSweep = clockwise ? arcEnd - arcStart : arcStart - arcEnd;

      // The bottom right corner.

      path.quadraticBezierTo(
        cos(endAngle) * r0 + center.dx,
        sin(endAngle) * r0 + center.dy,
        cos(arcEnd) * r0 + center.dx,
        sin(arcEnd) * r0 + center.dy,
      );

      // The bottom arc.

      path.arcTo(
        Rect.fromCircle(center: center, radius: r0),
        arcEnd,
        -arcSweep,
        false,
      );

      // The bottom left corner.
      path.quadraticBezierTo(
        cos(startAngle) * r0 + center.dx,
        sin(startAngle) * r0 + center.dy,
        cos(startAngle) * (r0 + bottomLeft.y) + center.dx,
        sin(startAngle) * (r0 + bottomLeft.y) + center.dy,
      );
    }

    path.close();

    return path;
  }
}

/// Positions of a cubic bezier segment.
class BezierSegment {
  BezierSegment(this.cp1, this.cp2, this.p);

  /// The first control point.
  final Offset cp1;

  /// The second contorl point.
  final Offset cp2;

  /// The target point.
  final Offset p;
}

/// Gets control points of a point list.
List<Offset> _getControlPoints(
  List<Offset> points,
  double ratio,
  bool isLoop,
  bool hasConstraint, [
  Rect? constraint,
]) {
  final vectors = points.map((point) => pointToVector(point)).toList();

  final cps = <Offset>[];
  Vector3 prevVector;
  Vector3 nextVector;
  Vector3? min;
  Vector3? max;

  // The real constraint is calculated as:
  // - If constraint is null, is the boundary of points.
  // - If constraint is not null, is the larger one of constraint and boundary of
  // points.
  if (hasConstraint) {
    min = Vector3(double.infinity, double.infinity, 0);
    max = Vector3(double.negativeInfinity, double.negativeInfinity, 0);

    for (var vector in vectors) {
      Vector3.min(min, vector, min);
      Vector3.max(max, vector, max);
    }
    if (constraint != null) {
      Vector3.min(min, pointToVector(constraint.topLeft), min);
      Vector3.max(max, pointToVector(constraint.bottomRight), max);
    }
  }

  final len = points.length;
  for (var i = 0; i < len; i++) {
    final vector = vectors[i];
    if (isLoop) {
      prevVector = vectors[i >= 1 ? i - 1 : len - 1];
      nextVector = vectors[(i + 1) % len];
    } else {
      if (i == 0 || i == len - 1) {
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

/// Produces a cubic Catmull–Rom spline.
List<BezierSegment> getBezierSegments(
  List<Offset> points,
  bool isLoop,
  bool hasConstraint, [
  Rect? constraint,
]) {
  // Alpha is 0.5, as proposed by Yuksel et al.
  // Thus is called a centripetal spline: https://en.wikipedia.org/wiki/Centripetal_Catmull%E2%80%93Rom_spline
  final controlPointList =
      _getControlPoints(points, 0.5, isLoop, hasConstraint, constraint);
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
