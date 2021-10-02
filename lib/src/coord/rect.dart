import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/util/map.dart';

import 'coord.dart';

class RectCoord extends Coord {
  RectCoord({
    this.horizontalRange,
    this.horizontalRangeSignal,
    this.verticalRange,
    this.verticalRangeSignal,

    int? dim,
    double? dimFill,
    bool? transposed,
  })
    : assert(horizontalRange == null || horizontalRange.length == 2),
      assert(verticalRange == null || verticalRange.length == 2),
      super(
        dim: dim,
        dimFill: dimFill,
        transposed: transposed,
      );

  List<double>? horizontalRange;

  Signal<List<double>>? horizontalRangeSignal;

  /// Rect coord is from bottom to top.
  List<double>? verticalRange;

  Signal<List<double>>? verticalRangeSignal;

  @override
  bool operator ==(Object other) =>
    other is RectCoord &&
    super == other &&
    DeepCollectionEquality().equals(horizontalRange, other.horizontalRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(horizontalRangeSignal, other.horizontalRangeSignal) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(verticalRange, other.verticalRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(verticalRangeSignal, verticalRangeSignal);  // SignalUpdata: Function
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
    : horizontals = [
        region.left + region.width * renderRangeX.first,
        region.left + region.width * renderRangeX.last,
      ],
      verticals = [
        region.bottom - region.height * renderRangeY.first,  // Rect coord is form bottom to top.
        region.bottom - region.height * renderRangeY.last,
      ],
      super(dim, dimFill, transposed, region);
    
  final List<double> horizontals;

  final List<double> verticals;

  @override
  Offset convert(Offset input) {
    if (dim == 1) {
      input = Offset(dimFill, input.dy);  // [arbitry domain, single measure]
    }

    final getHorizontalInput = transposed ? (Offset p) => p.dy : (Offset p) => p.dx;
    final getVerticalInput = transposed ? (Offset p) => p.dx : (Offset p) => p.dy;
    return Offset(
      horizontals.first + (horizontals.last - horizontals.first) * getHorizontalInput(input),
      verticals.first + (verticals.last - verticals.first) * getVerticalInput(input),
    );
  }

  @override
  Offset invert(Offset output) {
    final horizontalInput = (output.dx - horizontals.first) / (horizontals.last - horizontals.first);
    final verticalInput = (output.dy - verticals.first) / (verticals.last - verticals.first);
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
  RectCoordConv evaluate() {
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
