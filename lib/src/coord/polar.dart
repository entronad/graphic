import 'dart:ui';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/util/map.dart';
import 'package:graphic/src/util/transform.dart';
import 'package:vector_math/vector_math_64.dart';

import 'coord.dart';

class PolarCoord extends Coord {
  PolarCoord({
    this.angleRange,
    this.angleRangeSignals,
    this.radiusRange,
    this.radiusRangeSignals,

    int? dim,
    double? dimFill,
    bool? transposed,
  })
    : assert(angleRange == null || angleRange.length == 2),
      assert(radiusRange == null || radiusRange.length == 2),
      super(
        dim: dim,
        dimFill: dimFill,
        transposed: transposed,
      );

  final List<double>? angleRange;

  final List<Signal<List<double>>>? angleRangeSignals;

  final List<double>? radiusRange;

  final List<Signal<List<double>>>? radiusRangeSignals;

  @override
  bool operator ==(Object other) =>
    other is PolarCoord &&
    super == other &&
    DeepCollectionEquality().equals(angleRange, other.angleRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(angleRangeSignals, other.angleRangeSignals) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(radiusRange, other.radiusRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(radiusRangeSignals, radiusRangeSignals);  // SignalUpdata: Function
}

const canvasAngleStart = -pi / 2;

const canvasAngleEnd = 3 * pi / 2;

class PolarCoordConv extends CoordConv {
  PolarCoordConv(
    Rect region,
    int dim,
    double dimFill,
    bool transposed,
    List<double> renderRangeX,  // Render range is bind to render dim, ignoring tansposing.
    List<double> renderRangeY,
  )
    : center = region.center,
      angles = [
        canvasAngleStart + (canvasAngleEnd - canvasAngleStart) * renderRangeX.first,
        canvasAngleStart + (canvasAngleEnd - canvasAngleStart) * renderRangeX.last,
      ],
      radiuses = [
        min(region.width, region.height) / 2 * renderRangeY.first,
        min(region.width, region.height) / 2 * renderRangeY.last,
      ],
      super(dim, dimFill, transposed);

  final Offset center;

  final List<double> angles;

  final List<double> radiuses;

  /// abstractAngle to canvasAngle
  double convertAngle(double abstractAngle) =>
    angles.first + (angles.last - angles.first) * abstractAngle;

  /// abstractRadius to canvasRadius
  double convertRadius(double abstractRadius) =>
    radiuses.first + (radiuses.last - radiuses.first) * abstractRadius;
  
  /// canvasAngle to abstractAngle
  double invertAngle(double canvasAngle) =>
    (canvasAngle - angles.first) / (angles.last - angles.first);
  
  /// canvasRadius to abstarctRadius
  double invertRadius(double canvasRadius) =>
    (canvasRadius - radiuses.first) / (radiuses.last - radiuses.first);
  
  Offset polarToOffset(double canvasAngle, double canvasRadius) =>
    Offset(
      center.dx + cos(canvasAngle) * canvasRadius,
      center.dy + sin(canvasAngle) * canvasRadius,
    );

  @override
  Offset convert(Offset input) {
    if (dim == 1) {
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
    if ((theta - (canvasAngleEnd - canvasAngleStart)).abs() < 0.001) {
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
}

class PolarCoordConvOp extends CoordConvOp<PolarCoordConv> {
  PolarCoordConvOp(
    Map<String, dynamic> params,
  ) : super(params);

  @override
  PolarCoordConv update(Pulse pulse) {
    final region = params['region'] as Rect;
    final dim = params['dim'] as int;
    final dimFill = params['dimFill'] as double;
    final transposed = params['transposed'] as bool;
    final renderRangeX = params['renderRangeX'] as List<double>;
    final renderRangeY = params['renderRangeY'] as List<double>;
    return PolarCoordConv(
      region,
      dim,
      dimFill,
      transposed,
      renderRangeX,
      renderRangeY,
    );
  }
}
