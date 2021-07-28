import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
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
    double? dimFill,
    bool? transposed,
    Color? backgroundColor,
    Gradient? backgroundGradient,
  })
    : assert(horizontalRange == null || horizontalRange.length == 2),
      assert(verticalRange == null || verticalRange.length == 2),
      super(
        dim: dim,
        dimFill: dimFill,
        transposed: transposed,
        backgroundColor: backgroundColor,
        backgroundGradient: backgroundGradient,
      );

  final List<double>? horizontalRange;

  final List<Signal<List<double>>>? horizontalRangeSignals;

  /// Rect coord is from bottom to top.
  final List<double>? verticalRange;

  final List<Signal<List<double>>>? verticalRangeSignals;

  @override
  bool operator ==(Object other) =>
    other is RectCoord &&
    super == other &&
    DeepCollectionEquality().equals(horizontalRange, other.horizontalRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(horizontalRangeSignals, other.horizontalRangeSignals) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(verticalRange, other.verticalRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(verticalRangeSignals, verticalRangeSignals);  // SignalUpdata: Function
}

class RectCoordConv extends CoordConv {
  RectCoordConv(
    Rect region,
    int dim,
    double dimFill,
    bool transposed,
    List<double> renderRangeX,  // Render range is bind to render dim, ignoring tansposing.
    List<double> renderRangeY,
  )
    : horizontal = [
        region.left + region.width * renderRangeX.first,
        region.left + region.width * renderRangeX.last,
      ],
      vertical = [
        region.bottom - region.height * renderRangeY.first,  // Rect coord is form bottom to top.
        region.bottom - region.height * renderRangeY.last,
      ],
      super(dim, dimFill, transposed);
    
  final List<double> horizontal;

  final List<double> vertical;

  @override
  Offset convert(Offset input) {
    if (dim == 1) {
      input = Offset(dimFill, input.dy);  // [arbitry domain, single measure]
    }

    final getHorizontalInput = transposed ? (Offset p) => p.dy : (Offset p) => p.dx;
    final getVerticalInput = transposed ? (Offset p) => p.dx : (Offset p) => p.dy;
    return Offset(
      horizontal.first + (horizontal.last - horizontal.first) * getHorizontalInput(input),
      vertical.first + (vertical.last - vertical.first) * getVerticalInput(input),
    );
  }

  @override
  Offset invert(Offset output) {
    final horizontalInput = (output.dx - horizontal.first) / (horizontal.last - horizontal.first);
    final verticalInput = (output.dy - vertical.first) / (vertical.last - vertical.first);
    return transposed
      ? Offset(verticalInput, horizontalInput)
      : Offset(horizontalInput, verticalInput);
  }
}

class RectCoordConvOp extends CoordConvOp<RectCoordConv> {
  RectCoordConvOp(
    Map<String, dynamic> params,
  ) : super(params);

  @override
  RectCoordConv update(Pulse pulse) {
    final region = params['region'] as Rect;
    final dim = params['dim'] as int;
    final dimFill = params['dimFill'] as double;
    final transposed = params['transposed'] as bool;
    final renderRangeX = params['renderRangeX'] as List<double>;
    final renderRangeY = params['renderRangeY'] as List<double>;
    return RectCoordConv(
      region,
      dim,
      dimFill,
      transposed,
      renderRangeX,
      renderRangeY,
    );
  }
}
