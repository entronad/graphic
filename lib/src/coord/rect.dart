import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/util/map.dart';

import 'coord.dart';

class RectCoord extends Coord {
  RectCoord({
    this.horizontalRange,
    this.horizontalRangeSignals,
    this.verticalRange,
    this.verticalRangeSignals,

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

  final List<double>? horizontalRange;

  final List<Signal<double>>? horizontalRangeSignals;

  final List<double>? verticalRange;

  final List<Signal<double>>? verticalRangeSignals;

  @override
  bool operator ==(Object other) =>
    other is RectCoord &&
    super == other &&
    DeepCollectionEquality().equals(horizontalRange, other.horizontalRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(horizontalRangeSignals, other.horizontalRangeSignals) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(verticalRange, other.verticalRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(verticalRangeSignals, verticalRangeSignals);  // SignalUpdata: Function
}
