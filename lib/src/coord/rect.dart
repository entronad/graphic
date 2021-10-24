import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/util/map.dart';

import 'coord.dart';

/// The specification of a rectangle coordinate.
/// 
/// In a rectangle coordinate, dimensions are assigned to horizontal and vertical
/// directions.
/// 
/// Unlike the canvas coordinate, the vertical dimension direction is from bottom
/// to top.
class RectCoord extends Coord {
  /// Creates a rectangle coordinate.
  RectCoord({
    this.horizontalRange,
    this.onHorizontalRangeSignal,
    this.verticalRange,
    this.onVerticalRangeSignal,

    int? dimCount,
    double? dimFill,
    bool? transposed,
  })
    : assert(horizontalRange == null || horizontalRange.length == 2),
      assert(verticalRange == null || verticalRange.length == 2),
      super(
        dimCount: dimCount,
        dimFill: dimFill,
        transposed: transposed,
      );

  /// Range ratio of coordinate width to coordinate region width.
  /// 
  /// The list should have 2 items of start and end.
  /// 
  /// Coordinate region see details in [Coord].
  /// 
  /// If null, a default `[0, 1]` is set, meaning the same with coordinate region width.
  List<double>? horizontalRange;

  /// Signal update of [horizontalRange].
  SignalUpdate<List<double>>? onHorizontalRangeSignal;
  
  /// Range ratio of coordinate height to coordinate region height.
  /// 
  /// The list should have 2 items of start and end.
  /// 
  /// Coordinate region see details in [Coord].
  /// 
  /// If null, a default `[0, 1]` is set, meaning the same with coordinate region height.
  List<double>? verticalRange;

  /// Signal update of [verticalRange].
  SignalUpdate<List<double>>? onVerticalRangeSignal;

  @override
  bool operator ==(Object other) =>
    other is RectCoord &&
    super == other &&
    DeepCollectionEquality().equals(horizontalRange, other.horizontalRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(onHorizontalRangeSignal, other.onHorizontalRangeSignal) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(verticalRange, other.verticalRange) &&
    DeepCollectionEquality(MapKeyEquality()).equals(onVerticalRangeSignal, onVerticalRangeSignal);  // SignalUpdata: Function
}

/// The converter of a rectangle coordinate.
class RectCoordConv extends CoordConv {
  /// Creates a rectangle coordinate converter.
  /// 
  /// The render range parameters are of abstract dimensions, without transposint.
  RectCoordConv(
    Rect region,
    int dimCount,
    double dimFill,
    bool transposed,
    List<double> renderRangeX,
    List<double> renderRangeY,
  )
    : horizontals = [
        region.left + region.width * renderRangeX.first,
        region.left + region.width * renderRangeX.last,
      ],
      verticals = [
        region.bottom - region.height * renderRangeY.first,
        region.bottom - region.height * renderRangeY.last,
      ],
      super(dimCount, dimFill, transposed, region);
  
  /// Horizontal boundaries of the coordinate.
  final List<double> horizontals;

  /// Vertical boundaries of the coordinate.
  final List<double> verticals;

  @override
  Offset convert(Offset input) {
    if (dimCount == 1) {
      // The input domain value is arbitrary.
      input = Offset(dimFill, input.dy);
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

  @override
  double invertDistance(double canvasDistance, [int? dim]) {
    assert(dim == null || dim == 1 || dim == 2);
    final h = canvasDistance / (horizontals.last - horizontals.first).abs();
    final v = canvasDistance / (verticals.last - verticals.first).abs();
    if (dim == 1) {
      return transposed ? v : h;
    } else if (dim == 2) {
      return transposed ? h : v;
    } else { // null
      return (h + v) / 2;
    }
  }
}

class RectCoordConvOp extends CoordConvOp<RectCoordConv> {
  RectCoordConvOp(
    Map<String, dynamic> params,
  ) : super(params);

  @override
  RectCoordConv evaluate() {
    final region = params['region'] as Rect;
    final dimCount = params['dimCount'] as int;
    final dimFill = params['dimFill'] as double;
    final transposed = params['transposed'] as bool;
    final renderRangeX = params['renderRangeX'] as List<double>;
    final renderRangeY = params['renderRangeY'] as List<double>;
    return RectCoordConv(
      region,
      dimCount,
      dimFill,
      transposed,
      renderRangeX,
      renderRangeY,
    );
  }
}
