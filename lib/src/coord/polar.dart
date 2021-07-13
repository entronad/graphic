import 'dart:ui';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/operator/op_params.dart';
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
    bool? transposed,
    Color? backgroundColor,
    Gradient? backgroundGradient,
  })
    : assert(angleRange == null || angleRange.length == 2),
      assert(radiusRange == null || radiusRange.length == 2),
      super(
        dim: dim,
        transposed: transposed,
        backgroundColor: backgroundColor,
        backgroundGradient: backgroundGradient,
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

class PolarCoordConv extends CoordConv {
  PolarCoordConv(
    Rect region,
    int dim,
    bool transposed,
    List<double> renderRangeX,  // Render range is bind to render dim, ignoring tansposing.
    List<double> renderRangeY,
  )
    : center = region.center,
      angle = [
        -pi / 2 + 2 * pi * renderRangeX.first,
        -pi / 2 + 2 * pi * renderRangeX.last,
      ],
      radius = [
        min(region.width, region.height) / 2 * renderRangeY.first,
        min(region.width, region.height) / 2 * renderRangeY.last,
      ],
      super(dim, transposed);

  final Offset center;

  final List<double> angle;

  final List<double> radius;

  @override
  Offset convert(Offset input) {
    final getAngleInput = transposed ? (Offset p) => p.dy : (Offset p) => p.dx;
    final getRadiusInput = transposed ? (Offset p) => p.dx : (Offset p) => p.dy;

    final angleOutput = angle.first + (angle.last - angle.first) * getAngleInput(input);
    final radiusOutput = radius.first + (radius.last - radius.first) * getRadiusInput(input);

    return Offset(
      center.dx + cos(angleOutput) * radiusOutput,
      center.dy + sin(angleOutput) * radiusOutput,
    );
  }

  @override
  Offset invert(Offset output) {
    final axisX = Vector3(1, 0, 0);
    final startMatrix = Matrix4.rotationZ(angle.first);
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
    if ((theta - pi * 2).abs() < 0.001) {
      theta = 0;
    }
    final length = pointVector.length;
    final rangeXSwipe = (angle.last - angle.first).abs();
    final ratioX = theta / rangeXSwipe;
    final ratioY = (length - radius.first) / (radius.last - radius.first);
    return transposed
      ? Offset(ratioY, ratioX)
      : Offset(ratioX, ratioY);
  }
}

class PolarCoordConvOp extends CoordConvOp<PolarCoordConv> {
  PolarCoordConvOp(
    PolarCoordConv value,
    Map<String, dynamic> params,
  ) : super(value, params);

  @override
  PolarCoordConv update(OpParams params, Pulse pulse) {
    final region = params['region'] as Rect;
    final dim = params['dim'] as int;
    final transposed = params['transposed'] as bool;
    final renderRangeX = params['renderRangeX'] as List<double>;
    final renderRangeY = params['renderRangeY'] as List<double>;
    return PolarCoordConv(
      region,
      dim,
      transposed,
      renderRangeX,
      renderRangeY,
    );
  }
}
