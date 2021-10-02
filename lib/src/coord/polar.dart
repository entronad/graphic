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

class PolarCoord extends Coord {
  PolarCoord({
    this.startAngle,
    this.endAngle,
    this.innerRadius,
    this.radius,
    this.angleRange,
    this.angleRangeSignal,
    this.radiusRange,
    this.radiusRangeSignal,

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

  double? startAngle;

  double? endAngle;

  double? innerRadius;

  double? radius;

  List<double>? angleRange;

  Signal<List<double>>? angleRangeSignal;

  List<double>? radiusRange;

  Signal<List<double>>? radiusRangeSignal;

  @override
  bool operator ==(Object other) =>
    other is PolarCoord &&
    super == other &&
    startAngle == other.startAngle &&
    endAngle == other.endAngle &&
    innerRadius == other.innerRadius &&
    radius == other.radius &&
    DeepCollectionEquality().equals(angleRange, other.angleRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(angleRangeSignal, other.angleRangeSignal) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(radiusRange, other.radiusRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(radiusRangeSignal, radiusRangeSignal);  // SignalUpdata: Function
}

class PolarCoordConv extends CoordConv {
  PolarCoordConv(
    Rect region,
    int dim,
    double dimFill,
    bool transposed,
    List<double> renderRangeX,  // Render range is bind to render dim, ignoring tansposing.
    List<double> renderRangeY,
    double regionRadius,
    double startAngle,
    double endAngle,
    double innerRadius,
    double radius,
  )
    : this.startAngle = startAngle,
      this.endAngle = endAngle,
      this.innerRadius = innerRadius,
      this.radius = radius,
      center = region.center,
      angles = [
        startAngle + (endAngle - startAngle) * renderRangeX.first,
        startAngle + (endAngle - startAngle) * renderRangeX.last,
      ],
      radiuses = [
        innerRadius + (radius - innerRadius) * renderRangeY.first,
        innerRadius + (radius - innerRadius) * renderRangeY.last,
      ],
      super(dim, dimFill, transposed, region);

  final double startAngle;

  final double endAngle;

  final double innerRadius;

  final double radius;

  final Offset center;

  final List<double> angles;

  final List<double> radiuses;

  /// abstractAngle to canvasAngle
  double convertAngle(double abstractAngle) =>
    angles.first + (angles.last - angles.first) * abstractAngle;

  /// abstractRadius to canvasRadius
  double convertRadius(double abstractRadius) =>
    max(
      radiuses.first + (radiuses.last - radiuses.first) * abstractRadius,
      0,
    );
  
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
}

class PolarCoordConvOp extends CoordConvOp<PolarCoordConv> {
  PolarCoordConvOp(
    Map<String, dynamic> params,
  ) : super(params);

  @override
  PolarCoordConv evaluate() {
    final region = params['region'] as Rect;
    final dim = params['dim'] as int;
    final dimFill = params['dimFill'] as double;
    final transposed = params['transposed'] as bool;
    final renderRangeX = params['renderRangeX'] as List<double>;
    final renderRangeY = params['renderRangeY'] as List<double>;
    final startAngle = params['startAngle'] as double;
    final endAngle = params['endAngle'] as double;
    final innerRadius = params['innerRadius'] as double;
    final radius = params['radius'] as double;

    final regionRadius = region.shortestSide / 2;

    return PolarCoordConv(
      region,
      dim,
      dimFill,
      transposed,
      renderRangeX,
      renderRangeY,
      regionRadius,
      startAngle,
      endAngle,
      innerRadius * regionRadius,
      radius * regionRadius,
    );
  }
}
