import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/discrete.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/algebra/varset.dart';

import 'modifier.dart';

/// Only support uniform random in the band.
class JitterModifier extends Modifier {
  JitterModifier({
    this.ratio,
  });

  /// Distribution ratio of band.
  final double? ratio;

  @override
  bool operator ==(Object other) =>
    other is JitterModifier &&
    super == other &&
    ratio == other.ratio;
}

class JitterGeomModifier extends GeomModifer {
  JitterGeomModifier(
    this.ratio,
    this.band,
  );

  final double ratio;

  final double band;

  @override
  void modify(List<List<Tuple>> value) {
    final random = Random();

    for (var group in value) {
      for (var tuple in group) {
        final oldPosition = tuple['position'] as List<Offset>;
        final bias = ratio * band * (random.nextDouble() - 0.5);
        tuple['position'] = oldPosition.map(
          (point) => Offset(point.dx+ bias, point.dy),
        ).toList();
      }
    }
  }
}

class JitterGeomModifierOp extends GeomModiferOp<JitterGeomModifier> {
  JitterGeomModifierOp(Map<String, dynamic> params) : super(params);

  @override
  JitterGeomModifier update(Pulse pulse) {
    final ratio = params['ratio'] as double;
    final form = params['form'] as AlgForm;
    final scales = params['scales'] as Map<String, ScaleConv>;

    final xField = form.first[0];
    final band = (scales[xField] as DiscreteScaleConv).band!;

    return JitterGeomModifier(ratio, band);
  }
}
