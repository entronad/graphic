import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/discrete.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:graphic/src/algebra/varset.dart';

import 'modifier.dart';

/// The specification of a jitter modifier.
/// 
/// The jitter mothed moves objects randomly in their local neighborhood. The random
/// distribution is uniform.
class JitterModifier extends Modifier {
  /// Creates a jitter modifier.
  JitterModifier({
    this.ratio,
  });

  /// Ratio of the local neighborhood to the descrete band for each group.
  /// 
  /// If null, a default 0.5 is set.
  double? ratio;

  @override
  bool operator ==(Object other) =>
    other is JitterModifier &&
    super == other &&
    ratio == other.ratio;
}

class JitterGeomModifier extends GeomModifier {
  JitterGeomModifier(
    this.ratio,
    this.band,
  );

  final double ratio;

  final double band;

  @override
  void modify(AesGroups value) {
    final random = Random();

    for (var group in value) {
      for (var aes in group) {
        final oldPosition = aes.position;
        final bias = ratio * band * (random.nextDouble() - 0.5);
        aes.position = oldPosition.map(
          (point) => Offset(point.dx+ bias, point.dy),
        ).toList();
      }
    }
  }
}

class JitterGeomModifierOp extends GeomModifierOp<JitterGeomModifier> {
  JitterGeomModifierOp(Map<String, dynamic> params) : super(params);

  @override
  JitterGeomModifier evaluate() {
    final ratio = params['ratio'] as double;
    final form = params['form'] as AlgForm;
    final scales = params['scales'] as Map<String, ScaleConv>;

    final xField = form.first[0];
    final band = (scales[xField] as DiscreteScaleConv).band;

    return JitterGeomModifier(ratio, band);
  }
}
