import 'dart:ui';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/util/map.dart';
import 'package:graphic/src/util/transform.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:graphic/src/util/math.dart';

import 'coord.dart';

/// The specification of a polar coordinate.
/// 
/// In a polar coordinate, dimensions are assigned to angle and radius. The angles
/// are in radians.
/// 
/// The plane of a polar coordinate is defined not only by the coordinate region,
/// but also the starts and ends of angle and radius dimensions on canvas, which
/// are defined by [startAngle], [endAngle], [startRadius], and [endRadius].
class PolarCoord extends Coord {
  /// Creates a polar coord.
  PolarCoord({
    this.startAngle,
    this.endAngle,
    this.startRadius,
    this.endRadius,
    this.angleRange,
    this.onAngleRangeSignal,
    this.radiusRange,
    this.onRadiusRangeSignal,

    int? dimCount,
    double? dimFill,
    bool? transposed,
  })
    : assert(angleRange == null || angleRange.length == 2),
      assert(radiusRange == null || radiusRange.length == 2),
      super(
        dimCount: dimCount,
        dimFill: dimFill,
        transposed: transposed,
      );

  /// The start angle of the plane.
  /// 
  /// Note that for a canvas angle, zero radian is horizontally right toward from
  /// the center and positive is clockwise.
  /// 
  /// If null, a default `-pi / 2` is set.
  double? startAngle;

  /// The end angle of the plane.
  /// 
  /// Note that for a canvas angle, zero radian is horizontally right toward from
  /// the center and positive is clockwise.
  /// 
  /// If null, a default `3 * pi / 2` is set.
  double? endAngle;

  /// The start radius ratio of the plane to the minimum side of coordinate region.
  /// 
  /// If null, a default 0 is set.
  double? startRadius;

  /// The end radius ratio of the plane to the minimum side of coordinate region.
  /// 
  /// If null, a default 1 is set.
  double? endRadius;

  /// Range ratio of coordinate angle to plane angle.
  /// 
  /// The list should have 2 items of start and end.
  /// 
  /// The plane angle range is defined by [startAngle] and [endAngle].
  /// 
  /// If null, a default `[0, 1]` is set, meaning the same with plane angle.
  List<double>? angleRange;

  /// Signal update of [angleRange].
  SignalUpdate<List<double>>? onAngleRangeSignal;

  /// Range ratio of coordinate radius to plane radius.
  /// 
  /// The list should have 2 items of start and end.
  /// 
  /// The plane radius range is defined by [startRadius] and [endRadius].
  /// 
  /// If null, a default `[0, 1]` is set, meaning the same with plane radius.
  List<double>? radiusRange;

  /// Signal update of [radiusRange].
  SignalUpdate<List<double>>? onRadiusRangeSignal;

  @override
  bool operator ==(Object other) =>
    other is PolarCoord &&
    super == other &&
    startAngle == other.startAngle &&
    endAngle == other.endAngle &&
    startRadius == other.startRadius &&
    endRadius == other.endRadius &&
    DeepCollectionEquality().equals(angleRange, other.angleRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(onAngleRangeSignal, other.onAngleRangeSignal) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(radiusRange, other.radiusRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(onRadiusRangeSignal, onRadiusRangeSignal);  // SignalUpdata: Function
}

/// The converter of a polar coordinate.
class PolarCoordConv extends CoordConv {
  /// Creates a polar coordinate converter.
  /// 
  /// The render range parameters are of abstract dimensions, without transposint.
  PolarCoordConv(
    Rect region,
    int dimCount,
    double dimFill,
    bool transposed,
    List<double> renderRangeX,
    List<double> renderRangeY,
    double regionRadius,
    double startAngle,
    double endAngle,
    double startRadius,
    double endRadius,
  )
    : this.startAngle = startAngle,
      this.endAngle = endAngle,
      this.startRadius = startRadius,
      this.endRadius = endRadius,
      center = region.center,
      angles = [
        startAngle + (endAngle - startAngle) * renderRangeX.first,
        startAngle + (endAngle - startAngle) * renderRangeX.last,
      ],
      radiuses = [
        startRadius + (endRadius - startRadius) * renderRangeY.first,
        startRadius + (endRadius - startRadius) * renderRangeY.last,
      ],
      super(dimCount, dimFill, transposed, region);

  /// The [PolarCoord.startAngle].
  final double startAngle;

  /// The [PolarCoord.endAngle].
  final double endAngle;

  /// The start radius of the plane.
  final double startRadius;

  /// The end Radius of the plane.
  final double endRadius;

  /// The center of the polar coordinate.
  final Offset center;

  /// Start and end angles of the coordinate.
  final List<double> angles;

  /// Start and end radiuses of the coordinate.
  final List<double> radiuses;

  /// Converts an abstract angle to a canvas angle.
  double convertAngle(double abstractAngle) =>
    angles.first + (angles.last - angles.first) * abstractAngle;

  /// Converts an abstract radius to a canvas radius.
  double convertRadius(double abstractRadius) =>
    max(
      radiuses.first + (radiuses.last - radiuses.first) * abstractRadius,
      0,
    );
  
  /// Inverts a canvas angle to an abstract angle.
  double invertAngle(double canvasAngle) =>
    (canvasAngle - angles.first) / (angles.last - angles.first);
  
  /// Inverts a canvas radius to an abstract radius.
  double invertRadius(double canvasRadius) =>
    (canvasRadius - radiuses.first) / (radiuses.last - radiuses.first);
  
  /// Gets a canvas point form it's canvas angle and canvas radius.
  Offset polarToOffset(double canvasAngle, double canvasRadius) =>
    Offset(
      center.dx + cos(canvasAngle) * canvasRadius,
      center.dy + sin(canvasAngle) * canvasRadius,
    );

  @override
  Offset convert(Offset input) {
    if (dimCount == 1) {
      input = Offset(dimFill, input.dy);  // [arbitry domain, single measure]
    }

    final getAbstractAngle = transposed ? (Offset p) => p.dy : (Offset p) => p.dx;
    final getAbstractRadius = transposed ? (Offset p) => p.dx : (Offset p) => p.dy;

    return polarToOffset(
      convertAngle(getAbstractAngle(input)),
      convertRadius(getAbstractRadius(input)),
    );
  }

  @override
  Offset invert(Offset output) {
    final axisX = Vector3(1, 0, 0);
    final startMatrix = Matrix4.rotationZ(angles.first);
    final startVector = startMatrix.transformed3(axisX);
    final pointVector = Vector3(
      output.dx - center.dx,
      output.dy - center.dy,
      0,
    );
    if (vectorIsZero(pointVector)) {
      return Offset.zero;
    }

    var theta = vectorAngle(startVector, pointVector);
    if (theta.equalTo(pi * 2)) {
      theta = 0;
    }
    final length = pointVector.length;
    final rangeXSwipe = (angles.last - angles.first).abs();
    final ratioX = theta / rangeXSwipe;
    final ratioY = (length - radiuses.first) / (radiuses.last - radiuses.first);
    return transposed
      ? Offset(ratioY, ratioX)
      : Offset(ratioX, ratioY);
  }

  @override
  double invertDistance(double canvasDistance, [int? dim]) {
    assert(dim == null || dim == 1 || dim == 2);
    final a = canvasDistance / ((startRadius + endRadius) * 2); // arc length in middle radius.
    final r = canvasDistance / (endRadius - startRadius).abs();
    if (dim == 1) {
      return transposed ? r : a;
    } else if (dim == 2) {
      return transposed ? a : r;
    } else { // null
      return (a + r) / 2;
    }
  }
}

class PolarCoordConvOp extends CoordConvOp<PolarCoordConv> {
  PolarCoordConvOp(
    Map<String, dynamic> params,
  ) : super(params);

  @override
  PolarCoordConv evaluate() {
    final region = params['region'] as Rect;
    final dimCount = params['dimCount'] as int;
    final dimFill = params['dimFill'] as double;
    final transposed = params['transposed'] as bool;
    final renderRangeX = params['renderRangeX'] as List<double>;
    final renderRangeY = params['renderRangeY'] as List<double>;
    final startAngle = params['startAngle'] as double;
    final endAngle = params['endAngle'] as double;
    final startRadius = params['startRadius'] as double;
    final endRadius = params['endRadius'] as double;

    final regionRadius = region.shortestSide / 2;

    return PolarCoordConv(
      region,
      dimCount,
      dimFill,
      transposed,
      renderRangeX,
      renderRangeY,
      regionRadius,
      startAngle,
      endAngle,
      startRadius * regionRadius,
      endRadius * regionRadius,
    );
  }
}
