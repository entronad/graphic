import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

abstract class Coord {
  Coord({
    this.dim,
    this.dimFill,
    this.transposed,
    this.backgroundColor,
    this.backgroundGradient,
  })
    : assert(isSingle([backgroundColor, backgroundGradient], allowNone: true)),
      assert(dim == null || (dim >= 1 && dim <=2));

  final int? dim;

  /// The normal value in [0, 1] to fill the lack dim.
  final double? dimFill;

  final bool? transposed;

  final Color? backgroundColor;

  final Gradient? backgroundGradient;

  @override
  bool operator ==(Object other) =>
    other is Coord &&
    dim == other.dim &&
    dimFill == other.dimFill &&
    transposed == other.transposed &&
    backgroundColor == other.backgroundColor &&
    backgroundGradient == other.backgroundGradient;
}

/// Convert normal point to render point
/// If scaled value is continous, it is a dim of normal point dim directly,
///     but if is discrete, it will be transformd to [0, 1] before acting as normal point dim.
/// 
/// If dim == 1, only one dim of point is transposed, the other is to middle of the region.
abstract class CoordConv extends Converter<Offset, Offset> {
  CoordConv(
    this.dim,
    this.dimFill,
    this.transposed,
  );

  final int dim;

  final double dimFill;

  final bool transposed;
}

/// params:
/// All params needed to create a coord converter.
abstract class CoordConvOp<C extends CoordConv> extends Updater<C> {
  CoordConvOp(
    Map<String, dynamic> params,
  ) : super(params);  // The first value should be created in the first run.
}

/// params:
/// - groups: List<List<Tuple>>
/// - conv: CoordConv
/// 
/// value: List<List<Tuple>>, tuple groups
class CoordOp extends Updater<List<List<Tuple>>> {
  CoordOp(Map<String, dynamic> params) : super(params);

  @override
  List<List<Tuple>> update(Pulse pulse) {
    final groups = params['groups'] as List<List<Tuple>>;
    final conv = params['conv'] as CoordConv;

    for (var group in groups) {
      for (var tuple in group) {
        tuple['position'] = (tuple['position'] as List<Offset>)
          .map(conv.convert)
          .toList();
      }
    }

    return groups;
  }
}
