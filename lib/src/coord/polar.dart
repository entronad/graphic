import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/util/map.dart';

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
  }) : super(
    dim: dim,
    transposed: transposed,
    backgroundColor: backgroundColor,
    backgroundGradient: backgroundGradient,
  );

  final List<double>? angleRange;

  final List<Signal<double>>? angleRangeSignals;

  final List<double>? radiusRange;

  final List<Signal<double>>? radiusRangeSignals;

  @override
  bool operator ==(Object other) =>
    other is PolarCoord &&
    super == other &&
    DeepCollectionEquality().equals(angleRange, other.angleRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(angleRangeSignals, other.angleRangeSignals) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(radiusRange, other.radiusRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(radiusRangeSignals, radiusRangeSignals);  // SignalUpdata: Function
}
