import 'package:flutter/painting.dart';
import 'package:graphic/src/chart/chart_view.dart';
import 'package:graphic/src/common/dim.dart';
import 'package:graphic/src/graffiti/element/element.dart';
import 'package:graphic/src/graffiti/element/rect.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/util/collection.dart';

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
    this.horizontalRangeUpdater,
    this.verticalRange,
    this.verticalRangeUpdater,
    int? dimCount,
    double? dimFill,
    bool? transposed,
    Color? color,
    Gradient? gradient,
  })  : assert(horizontalRange == null || horizontalRange.length == 2),
        assert(verticalRange == null || verticalRange.length == 2),
        super(
          dimCount: dimCount,
          dimFill: dimFill,
          transposed: transposed,
          color: color,
          gradient: gradient,
        );

  /// Range ratio of coordinate width to coordinate region width.
  ///
  /// The list should have 2 items of start and end.
  ///
  /// Coordinate region see details in [Coord].
  ///
  /// If null, a default `[0, 1]` is set, meaning the same with coordinate region width.
  List<double>? horizontalRange;

  /// Event updater of [horizontalRange].
  EventUpdater<List<double>>? horizontalRangeUpdater;

  /// Range ratio of coordinate height to coordinate region height.
  ///
  /// The list should have 2 items of start and end.
  ///
  /// Coordinate region see details in [Coord].
  ///
  /// If null, a default `[0, 1]` is set, meaning the same with coordinate region height.
  List<double>? verticalRange;

  /// Event updater of [verticalRange].
  EventUpdater<List<double>>? verticalRangeUpdater;

  @override
  bool operator ==(Object other) =>
      other is RectCoord &&
      super == other &&
      deepCollectionEquals(horizontalRange, other.horizontalRange) &&
      deepCollectionEquals(verticalRange, other.verticalRange);
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
  )   : horizontals = [
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
      // For 1D coordinate, the domain dimension of input is arbitry.
      input = Offset(dimFill, input.dy);
    }

    final getHorizontalInput =
        transposed ? (Offset p) => p.dy : (Offset p) => p.dx;
    final getVerticalInput =
        transposed ? (Offset p) => p.dx : (Offset p) => p.dy;
    return Offset(
      horizontals.first +
          (horizontals.last - horizontals.first) * getHorizontalInput(input),
      verticals.first +
          (verticals.last - verticals.first) * getVerticalInput(input),
    );
  }

  @override
  Offset invert(Offset output) {
    final horizontalInput = (output.dx - horizontals.first) /
        (horizontals.last - horizontals.first);
    final verticalInput =
        (output.dy - verticals.first) / (verticals.last - verticals.first);
    return transposed
        ? Offset(verticalInput, horizontalInput)
        : Offset(horizontalInput, verticalInput);
  }

  @override
  double invertDistance(double canvasDistance, [Dim? dim]) {
    final h = canvasDistance / (horizontals.last - horizontals.first).abs();
    final v = canvasDistance / (verticals.last - verticals.first).abs();
    if (dim == Dim.x) {
      return transposed ? v : h;
    } else if (dim == Dim.y) {
      return transposed ? h : v;
    } else {
      return (h + v) / 2;
    }
  }
}

/// The rectangle coordinate converter operator
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

/// The rectangle region color render operator.
class RectRegionColorRenderOp extends RegionBackgroundRenderOp {
  RectRegionColorRenderOp(
    Map<String, dynamic> params,
    MarkScene scene,
    ChartView view,
  ) : super(params, scene, view);

  @override
  void render() {
    final region = params['region'] as Rect;
    final color = params['color'] as Color;

    scene.set([RectElement(rect: region, style: PaintStyle(fillColor: color))]);
  }
}

/// The rectangle region gradient render operator.
class RectRegionGradientRenderOp extends RegionBackgroundRenderOp {
  RectRegionGradientRenderOp(
    Map<String, dynamic> params,
    MarkScene scene,
    ChartView view,
  ) : super(params, scene, view);

  @override
  void render() {
    final region = params['region'] as Rect;
    final gradient = params['gradient'] as Gradient;

    scene.set([
      RectElement(
          rect: region,
          style: PaintStyle(fillGradient: gradient, gradientBounds: region))
    ]);
  }
}
