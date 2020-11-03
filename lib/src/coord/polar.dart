import 'dart:ui';
import 'dart:math';

import 'package:vector_math/vector_math_64.dart';
import 'package:graphic/src/util/transform.dart';

import 'base.dart';

double _getX(Offset point) => point.dx;

double _getY(Offset point) => point.dy;

class PolarCoord extends Coord {
  PolarCoord({
    bool transposed,

    double radius,
    double innerRadius,
    double startAngle,
    double endAngle,
  }) {
    this['transposed'] = transposed;
    this['radius'] = radius;
    this['innerRadius'] = innerRadius;
    this['startAngle'] = startAngle;
    this['endAngle'] = endAngle;
  }

  @override
  CoordType get type => CoordType.polar;
}

class PolarCoordState extends CoordState {
  double get radius => this['radius'] as double;
  set radius(double value) => this['radius'] = value;

  double get innerRadius => this['innerRadius'] as double;
  set innerRadius(double value) => this['innerRadius'] = value;

  double get startAngle => this['startAngle'] as double;
  set startAngle(double value) => this['startAngle'] = value;

  double get endAngle => this['endAngle'] as double;
  set endAngle(double value) => this['endAngle'] = value;
}

class PolarCoordComponent extends CoordComponent<PolarCoordState> {
  PolarCoordComponent([PolarCoord props]) : super(props);

  @override
  PolarCoordState createState() => PolarCoordState();

  @override
  void initDefaultState() {
    super.initDefaultState();
    state
      ..radius = 1
      ..innerRadius = 0
      ..startAngle = -pi / 2
      ..endAngle = pi * 3 / 2;
  }

  double _radiusLength;

  double get radiusLength => _radiusLength;

  Offset _center;

  Offset get center => _center;

  @override
  List<double> get rangeX => [
    state.startAngle,
    state.endAngle,
  ];

  @override
  List<double> get rangeY => [
    _radiusLength * state.innerRadius,
    _radiusLength,
  ];

  @override
  Offset convertPoint(Offset abstractPoint) {
    final transposed = state.transposed;
    final xDim = transposed ? _getY : _getX;
    final yDim = transposed ? _getX : _getY;

    final angle = rangeX.first + (rangeX.last - rangeX.first) * xDim(abstractPoint);
    final radius = rangeY.first + (rangeY.last - rangeY.first) * yDim(abstractPoint);

    return Offset(
      _center.dx + cos(angle) * radius,
      _center.dy + sin(angle) * radius,
    );
  }

  @override
  Offset invertPoint(Offset renderPoint) {
    final axisX = Vector3(1, 0, 0);
    final startMatrix = Matrix4.rotationZ(rangeX.first);
    final startVector = startMatrix.transformed3(axisX);
    final pointVector = Vector3(
      renderPoint.dx - _center.dx,
      renderPoint.dy - _center.dy,
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
    final rangeXSwipe = (rangeX.last - rangeX.first).abs();
    final ratioX = theta / rangeXSwipe;
    final ratioY = (length - rangeY.first) / (rangeY.last - rangeY.first);
    return state.transposed
      ? Offset(ratioY, ratioX)
      : Offset(ratioX, ratioY);
  }

  @override
  void onSetRegion() {
    super.onSetRegion();

    final region = state.region;
    double maxRadiusLength;
    Offset center;
    if (state.startAngle == -pi && state.endAngle == 0) {
      // Special for gauge

      maxRadiusLength = min(region.width / 2, region.height);
      center = Offset(region.center.dx, region.bottom);
    } else {
      maxRadiusLength = min(region.width, region.height) / 2;
      center = region.center;
    }

    _center = center;
    _radiusLength = maxRadiusLength * state.radius;
  }
}
