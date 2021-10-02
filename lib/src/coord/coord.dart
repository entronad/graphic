import 'dart:ui';
import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';

import 'rect.dart';
import 'polar.dart';

abstract class Coord {
  Coord({
    this.dim,
    this.dimFill,
    this.transposed,
  }) : assert(dim == null || (dim >= 1 && dim <=2));

  /// 1: Only has measure dim, the domain dim is dimFill.
  /// 2: Has both domain and measure dim.
  int? dim;

  /// The normal value in [0, 1] to fill the domain dim.
  double? dimFill;

  bool? transposed;

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
    this.region,
  );

  final int dim;

  final double dimFill;

  final bool transposed;

  final Rect region;

  int getCanvasDim(int abstractDim) =>
    dim == 1
      ? (transposed ? 1 : 2) // The last one is the value dim.
      : (transposed ? (3 - abstractDim) : abstractDim);
}

/// params:
/// All params needed to create a coord converter.
abstract class CoordConvOp<C extends CoordConv> extends Operator<C> {
  CoordConvOp(
    Map<String, dynamic> params,
  ) : super(params);  // The first value should be created in the first run.
}

class RegionOp extends Operator<Rect> {
  RegionOp(
    Map<String, dynamic> params,
  ) : super(params);

  @override
  Rect evaluate() {
    final size = params['size'] as Size;
    final padding = params['padding'] as EdgeInsets;

    final container = Rect.fromLTWH(0, 0, size.width, size.height);
    return padding.deflateRect(container);
  }
}

void parseCoord(
  Spec spec,
  View view,
  Scope scope,
) {
  final region = view.add(RegionOp({
    'size': scope.size,
    'padding': spec.padding ?? (
      spec.coord is PolarCoord
        ? EdgeInsets.all(40)
        : EdgeInsets.fromLTRB(40, 5, 10, 20)
    ),
  }));

  final coordSpec = spec.coord ?? RectCoord();

  if (coordSpec is RectCoord) {
    Operator<List<double>> horizontalRange = view.add(Value<List<double>>(
      coordSpec.horizontalRange ?? [0, 1],
    ));
    if (coordSpec.horizontalRangeSignal != null) {
      horizontalRange = view.add(SignalUpdateOp({
        'spec': coordSpec.horizontalRangeSignal,
        'initialValue': horizontalRange,
        'signal': scope.signal,
      }));
    }
    Operator<List<double>> verticalRange = view.add(Value<List<double>>(
      coordSpec.verticalRange ?? [0, 1],
    ));
    if (coordSpec.verticalRangeSignal != null) {
      verticalRange = view.add(SignalUpdateOp({
        'spec': coordSpec.verticalRangeSignal,
        'initialValue': verticalRange,
        'signal': scope.signal,
      }));
    }

    scope.coord = view.add(RectCoordConvOp({
      'region': region,
      'dim': coordSpec.dim ?? 2,
      'dimFill': coordSpec.dimFill ?? 0.5,
      'transposed': coordSpec.transposed ?? false,
      'renderRangeX': horizontalRange,
      'renderRangeY': verticalRange,
    }));
  } else {
    coordSpec as PolarCoord;
    Operator<List<double>> angleRange = view.add(Value<List<double>>(
      coordSpec.angleRange ?? [0, 1],
    ));
    if (coordSpec.angleRangeSignal != null) {
      angleRange = view.add(SignalUpdateOp({
        'spec': coordSpec.angleRangeSignal,
        'initialValue': angleRange,
        'signal': scope.signal,
      }));
    }
    Operator<List<double>> radiusRange = view.add(Value<List<double>>(
      coordSpec.radiusRange ?? [0, 1],
    ));
    if (coordSpec.radiusRangeSignal != null) {
      radiusRange = view.add(SignalUpdateOp({
        'spec': coordSpec.radiusRangeSignal,
        'initialValue': radiusRange,
        'signal': scope.signal,
      }));
    }

    scope.coord = view.add(PolarCoordConvOp({
      'region': region,
      'dim': coordSpec.dim ?? 2,
      'dimFill': coordSpec.dimFill ?? 0.5,
      'transposed': coordSpec.transposed ?? false,
      'renderRangeX': angleRange,
      'renderRangeY': radiusRange,
      'startAngle': coordSpec.startAngle ?? (-pi / 2),
      'endAngle': coordSpec.endAngle ?? (3 * pi / 2),
      'innerRadius': coordSpec.innerRadius ?? 0.0,
      'radius': coordSpec.radius ?? 1.0,
    }));
  }
}
