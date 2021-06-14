import 'package:graphic/src/control/signal.dart';

import 'base.dart';

class PolarCoord extends Coord {
  PolarCoord({
    this.angleRange,
    this.angleRangeSignal,
    this.radiusRange,
    this.radiusRangeSignal,

    int? dim,
    bool? transposed,
  }) : super(
    dim: dim,
    transposed: transposed,
  );

  final List<double>? angleRange;

  final List<Signal<double>>? angleRangeSignal;

  final List<double>? radiusRange;

  final List<Signal<double>>? radiusRangeSignal;
}
