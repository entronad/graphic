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
  bool equalTo(Object other) =>
      other is DodgeModifier &&
      super == other &&
      ratio == other.ratio &&
      symmetric == other.symmetric;

  @override
  void modify(AesGroups aesGroups, Map<String, ScaleConv<dynamic, num>> scales,
      AlgForm form, Offset origin) {
    final xField = form.first[0];
    final band = (scales[xField] as DiscreteScaleConv).band;

    final ratio = this.ratio ?? 1 / (aesGroups.length);
    final symmetric = this.symmetric ?? true;

    final bias = ratio * band;
    // If symmetric, negtively shifts half of the total bias.
    var accumulated = symmetric ? -bias * (aesGroups.length - 1) / 2 : 0.0;

    for (var group in aesGroups) {
      for (var aes in group) {
        final oldPosition = aes.position;
        aes.position = oldPosition
            .map(
              (point) => Offset(point.dx + accumulated, point.dy),
            )
            .toList();
      }
      accumulated += bias;
    }
  }
}
