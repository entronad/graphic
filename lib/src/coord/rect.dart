import 'package:graphic/src/control/signal.dart';

import 'base.dart';

class RectCoord extends Coord {
  RectCoord({
    this.horizontalRange,
    this.horizontalRangeSignal,
    this.verticalRange,
    this.verticalRangeSignal,

    int? dim,
    bool? transposed,
  }) : super(
    dim: dim,
    transposed: transposed,
  );

  final List<double>? horizontalRange;

  final List<Signal<double>>? horizontalRangeSignal;

  final List<double>? verticalRange;

  final List<Signal<double>>? verticalRangeSignal;
}
