import 'dart:ui';

import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/discrete.dart';
import 'package:graphic/src/scale/scale.dart';

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

  /// The dodge ratio to the discrete band for each group.
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

/// The dodge geometry modifier.
class DodgeGeomModifier extends GeomModifier {
  DodgeGeomModifier(
    this.ratio,
    this.symmetric,
    this.band,
  );

  /// The dodge ratio to the discrete band for each group. Its range is ]0, 1].
  final double ratio;

  /// Whether the dodge will go both side around the original x or only positive
  /// side.
  /// If false, every [Aes] will be shifted in the positive direction of the X
  /// axis by [ratio]*[band].
  /// If true, every [Aes] will be centered around its original offset.
  final bool symmetric;

  /// The band ratio of each value. It represents the width of the interval the
  /// [Aes]es have to position themselves within.
  /// Its range is ]0, 1].
  final double band;

  @override
  void modify(AesGroups value) {
    final bias = ratio * band;
    final numGroups = value.length;

    // When symmetric, add a negative accumulation so that values are shifted
    // left and centered around the original value.
    var accumulated = symmetric ? -bias * (numGroups + 1) / 2 : 0.0;

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
  }
}

/// The dodge geometry modifier operator.
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
