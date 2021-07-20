import 'dart:ui';

import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/discrete.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/algebra/varset.dart';

import 'modifier.dart';

class DodgeModifier extends Modifier {
  DodgeModifier({
    this.ratio,
    this.symmetric,
  });

  /// Dodge ratio of band for each group.
  final double? ratio;

  final bool? symmetric;

  @override
  bool operator ==(Object other) =>
    other is DodgeModifier &&
    super == other &&
    ratio == other.ratio &&
    symmetric == other.symmetric;
}

class DodgeGeomModifier extends GeomModifer {
  DodgeGeomModifier(
    this.ratio,
    this.symmetric,
    this.band,
  );

  final double ratio;

  final bool symmetric;

  final double band;

  @override
  void modify(List<List<Tuple>> value) {
    final bias = ratio * band;
    var accumulated = 0.0;

    for (var group in value) {
      for (var tuple in group) {
        final oldPosition = tuple['position'] as List<Offset>;
        tuple['position'] = oldPosition.map(
          (point) => Offset(point.dx + accumulated + bias, point.dy),
        ).toList();
      }
      accumulated += bias;
    }

    if (symmetric) {
      final symmetricBias = - accumulated / 2;
      for (var group in value) {
        for (var tuple in group) {
          final oldPosition = tuple['position'] as List<Offset>;
          tuple['position'] = oldPosition.map(
            (point) => Offset(point.dx + symmetricBias, point.dy),
          ).toList();
        }
      }
    }
  }
}

class DodgeGeomModifierOp extends GeomModiferOp<DodgeGeomModifier> {
  DodgeGeomModifierOp(Map<String, dynamic> params) : super(params);

  @override
  DodgeGeomModifier update(Pulse pulse) {
    final ratio = params['ratio'] as double;
    final symmetric = params['symmetric'] as bool;
    final form = params['form'] as AlgForm;
    final scales = params['scales'] as Map<String, ScaleConv>;

    final xField = form.first[0];
    final band = (scales[xField] as DiscreteScaleConv).band!;

    return DodgeGeomModifier(ratio, symmetric, band);
  }
}
