import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/common/typed_map.dart';
import 'package:graphic/src/common/base_classes.dart';

import 'base.dart';

double _getX(Offset point) => point.dx;

double _getY(Offset point) => point.dy;

class PolarCoord extends Props<CoordType> {
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
  PolarCoordComponent(TypedMap cfg) : super(cfg);

  @override
  PolarCoordState get originalState => PolarCoordState();

  @override
  void initDefaultState() {
    state
      ..radius = 1
      ..innerRadius = 0
      ..startAngle = -pi / 2
      ..endAngle = pi * 3 / 2;
  }

  double _radiusLength;

  double get radiusLength => _radiusLength;

  Offset _center;

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
  Offset convertPoint(Offset point) {
    final transposed = state.transposed;
    final xDim = transposed ? _getY : _getX;
    final yDim = transposed ? _getX : _getY;

    final angle = rangeX.first + (rangeX.last - rangeX.first) * xDim(point);
    final radius = rangeY.first + (rangeY.last - rangeY.first) * yDim(point);

    return Offset(
      _center.dx + cos(angle) * radius,
      _center.dy + sin(angle) * radius,
    );
  }

  @override
  Offset invertPoint(Offset point) {

  }

  @override
  void onSetPlot() {
    super.onSetPlot();

    final plot = state.plot;
    double maxRadiusLength;
    Offset center;
    if (state.startAngle == -pi && state.endAngle == 0) {
      // Special for gauge

      maxRadiusLength = min(plot.width / 2, plot.height);
      center = Offset(plot.center.dx, plot.bottom);
    } else {
      maxRadiusLength = min(plot.width, plot.height) / 2;
      center = plot.center;
    }

    _center = center;
    _radiusLength = maxRadiusLength * state.radius;
  }
}
