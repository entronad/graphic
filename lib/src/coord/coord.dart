import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/util/assert.dart';

abstract class Coord {
  Coord({
    this.dim,
    this.transposed,
    this.backgroundColor,
    this.backgroundGradient,
  })
    : assert(isSingle([backgroundColor, backgroundGradient], allowNone: true)),
      assert(dim == null || (dim >= 1 && dim <=2));

  final int? dim;

  final bool? transposed;

  final Color? backgroundColor;

  final Gradient? backgroundGradient;

  @override
  bool operator ==(Object other) =>
    other is Coord &&
    dim == other.dim &&
    transposed == other.transposed &&
    backgroundColor == other.backgroundColor &&
    backgroundGradient == other.backgroundGradient;
}

/// abstract point to render point
/// If scaled value is continous, it is a dim of abstract point dim directly,
///     but if is discrete, it will be transformd to [0, 1] before acting as abstract point dim.
/// 
/// If dim == 1, only one dim of point is transposed, the other is to middle of the region.
abstract class CoordConv extends Converter<Offset, Offset> {
  CoordConv(
    this.dim,
    this.transposed,
  );

  final int dim;

  final bool transposed;
}

/// params:
/// All params needed to create a coord converter.
abstract class CoordConvOp<C extends CoordConv> extends Updater<C> {
  CoordConvOp(
    C value,
    Map<String, dynamic> params,
  ) : super(value, params);
}
