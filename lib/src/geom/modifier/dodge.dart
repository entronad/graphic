import 'dart:ui';

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/discrete.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/algebra/varset.dart';

import 'modifier.dart';

/// The specification of a dodge modifier.
///
/// The dodge method moves objects around locally so they do not collide.
class DodgeModifier extends Modifier {
  /// Creates a dodge modifier.
  DodgeModifier({
    this.ratio,
    this.symmetric,
  });

  /// Dodge ratio to the descrete band for each group.
  ///
  /// If null, a default reciprocal of group counts is set.
  double? ratio;

  /// Whether the dodge will go both side around the original x or only positive
  /// side.
  ///
  /// If null, a default true is set.
  bool? symmetric;

  @override
  bool operator ==(Object other) =>
      other is DodgeModifier &&
      super == other &&
      ratio == other.ratio &&
      symmetric == other.symmetric;
}

class DodgeGeomModifier extends GeomModifier {
  DodgeGeomModifier(
    this.ratio,
    this.symmetric,
    this.band,
  );

  final double ratio;

  final bool symmetric;

  final double band;

  @override
  void modify(AesGroups value) {
    final bias = ratio * band;
    var accumulated = 0.0;

    for (var group in value) {
      for (var aes in group) {
        final oldPosition = aes.position;
        aes.position = oldPosition
            .map(
              (point) => Offset(point.dx + accumulated + bias, point.dy),
            )
            .toList();
      }
      accumulated += bias;
    }

    if (symmetric) {
      final symmetricBias = -accumulated / 2;
      for (var group in value) {
        for (var aes in group) {
          final oldPosition = aes.position;
          aes.position = oldPosition
              .map(
                (point) => Offset(point.dx + symmetricBias, point.dy),
              )
              .toList();
        }
      }
    }
  }
}

class DodgeGeomModifierOp extends GeomModifierOp<DodgeGeomModifier> {
  DodgeGeomModifierOp(Map<String, dynamic> params) : super(params);

  @override
  DodgeGeomModifier evaluate() {
    final ratio = params['ratio'] as double?;
    final symmetric = params['symmetric'] as bool;
    final form = params['form'] as AlgForm;
    final scales = params['scales'] as Map<String, ScaleConv>;
    final groups = params['groups'] as AesGroups;

    final xField = form.first[0];
    final band = (scales[xField] as DiscreteScaleConv).band;

    return DodgeGeomModifier(
      ratio ?? 1 / (groups.length),
      symmetric,
      band,
    );
  }
}
