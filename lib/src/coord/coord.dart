import 'package:flutter/painting.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/common/dim.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/util/assert.dart';

import 'rect.dart';
import 'polar.dart';

/// Specification of the coordinate.
///
/// As in a plane, The count of coordinate dimensions can be 1 or 2 (Which is set
/// by [dimCount]).
///
/// For a 2 dimensions coordinate, the coordinate will have both **domain dimension**
/// (usually denoted as "x") and **measure dimension** (usually denoted as "y").
///
/// For a 1 dimension coordinate, the coordinate will only have measure dimension,
/// and all points' domain dimensions will be set to [dimFill] for rendering position.
///
/// The **coordinate region** is the visual boundary rectangle of the coordinate
/// on the chart widget. It is determined by chart size and padding. the coordinate
/// range may be smaller or larger than the region. The range properties of [RectCoord]
/// and [PolarCoord] is are define in ratio to coordinate region.
abstract class Coord {
  /// Creates a coordinate.
  Coord({
    this.dimCount,
    this.dimFill,
    this.transposed,
    this.color,
    this.gradient,
  })  : assert(dimCount == null || (dimCount >= 1 && dimCount <= 2)),
        assert(isSingle([color, gradient], allowNone: true));

  /// The count of coordinate dimensions.
  ///
  /// If null, a default 2 is set.
  int? dimCount;

  /// The position value to fill the domain dimension when [dimCount] is 1.
  ///
  /// It is a normalized value of `[0, 1]`.
  ///
  /// If null, a default 0.5 is set, which means in the middle of the dimension.
  double? dimFill;

  /// Weither to transpose domain dimension and measure dimension.
  bool? transposed;

  /// The color of this coordinate region.
  Color? color;

  /// The gradient of this coordinate region.
  Gradient? gradient;

  /// The layer of this coordinate region background.
  int? layer;

  @override
  bool operator ==(Object other) =>
      other is Coord &&
      dimCount == other.dimCount &&
      dimFill == other.dimFill &&
      transposed == other.transposed &&
      color == other.color &&
      gradient == other.gradient;
}

/// The converter of a coordinate.
///
/// The inputs are abstract position points from [Attributes.position] and outputs are
/// canvas points.
abstract class CoordConv extends Converter<Offset, Offset> {
  /// Creates a coordinate converter.
  CoordConv(
    this.dimCount,
    this.dimFill,
    this.transposed,
    this.region,
  );

  /// The [Coord.dimCount].
  final int dimCount;

  /// The [Coord.dimFill].
  final double dimFill;

  /// The [Coord.transposed].
  final bool transposed;

  /// The coordinate region.
  final Rect region;

  /// Transforms an abstract dimension to canvas dimension according to whether
  /// [transposed].
  Dim getCanvasDim(Dim abstractDim) => dimCount == 1
      // The last dimension is the mearure dimension.
      ? (transposed ? Dim.x : Dim.y)
      : (transposed ? (abstractDim == Dim.x ? Dim.y : Dim.x) : abstractDim);

  /// Inverts a distance in canvas to abstract distance.
  double invertDistance(double canvasDistance, [Dim? dim]);
}

/// The operator to create the coordinate converter.
abstract class CoordConvOp<C extends CoordConv> extends Operator<C> {
  CoordConvOp(
    Map<String, dynamic> params,
  ) : super(params);
}

/// The operator to create the coordinate region.
class RegionOp extends Operator<Rect> {
  RegionOp(
    Map<String, dynamic> params,
  ) : super(params);

  @override
  Rect evaluate() {
    final size = params['size'] as Size;
    final padding = params['padding'] as EdgeInsets Function(Size);

    final container = Rect.fromLTWH(0, 0, size.width, size.height);
    return padding(size).deflateRect(container);
  }
}

/// The region background render operator.
abstract class RegionBackgroundRenderOp extends Render {
  RegionBackgroundRenderOp(
    Map<String, dynamic> params,
    MarkScene scene,
    ChartView view,
  ) : super(params, scene, view);
}
