import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';

abstract class Coord {
  Coord({
    this.dim,
    this.dimFill,
    this.transposed,
  }) : assert(dim == null || (dim >= 1 && dim <=2));

  /// 1: Only has measure dim, the domain dim is dimFill.
  /// 2: Has both domain and measure dim.
  final int? dim;

  /// The normal value in [0, 1] to fill the domain dim.
  final double? dimFill;

  final bool? transposed;

  @override
  bool operator ==(Object other) =>
    other is Coord &&
    dim == other.dim &&
    dimFill == other.dimFill &&
    transposed == other.transposed;
}

/// Convert abstract point to canvas point
abstract class CoordConv extends Converter<Offset, Offset> {
  CoordConv(
    this.dim,
    this.dimFill,
    this.transposed,
  );

  final int dim;

  final double dimFill;

  final bool transposed;

  int getCanvasDim(int dim) =>
    transposed ? (3 - dim) : dim;
}

/// params:
/// All params needed to create a coord converter.
abstract class CoordConvOp<C extends CoordConv> extends Updater<C> {
  CoordConvOp(
    Map<String, dynamic> params,
  ) : super(params);  // The first value should be created in the first run.
}

class RegionOp extends Updater<Rect> {
  RegionOp(
    Map<String, dynamic> params,
  ) : super(params);

  @override
  Rect update(Pulse pulse) {
    final size = params['size'] as Size;
    final padding = params['padding'] as EdgeInsets;

    final container = Rect.fromLTWH(0, 0, size.width, size.height);
    return padding.deflateRect(container);
  }
}
