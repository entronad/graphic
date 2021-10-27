import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/dataflow/tuple.dart';

import 'modifier.dart';

/// The specification of a symmetric modifier.
///
/// The symmetric method redistributes all position points symmetricly around the
/// zero, keeping their relative position unchanged.
class SymmetricModifier extends Modifier {
  @override
  bool operator ==(Object other) =>
      other is SymmetricModifier && super == other;
}

class SymmetricGeomModifier extends GeomModifier {
  SymmetricGeomModifier(this.normalZero);

  final double normalZero;

  /// The points will be re-distributed symmetric to zero x line, keeping the relative distance.
  /// Symmetric is mostly used in river chart, funnel chart.
  @override
  void modify(AesGroups value) {
    for (var i = 0; i < value.first.length; i++) {
      var minY = double.infinity;
      var maxY = double.negativeInfinity;
      for (var group in value) {
        final aes = group[i];
        for (var point in aes.position) {
          final y = point.dy;
          if (y.isFinite) {
            minY = min(minY, y);
            maxY = max(maxY, y);
          }
        }
      }

      final symmetricBias = normalZero - (minY + maxY) / 2;
      for (var group in value) {
        final aes = group[i];
        final oldPosition = aes.position;
        aes.position = oldPosition
            .map(
              (point) => Offset(point.dx, point.dy + symmetricBias),
            )
            .toList();
      }
    }
  }
}

class SymmetricGeomModifierOp extends GeomModifierOp<SymmetricGeomModifier> {
  SymmetricGeomModifierOp(Map<String, dynamic> params) : super(params);

  @override
  SymmetricGeomModifier evaluate() {
    final origin = params['origin'] as Offset;

    return SymmetricGeomModifier(origin.dy);
  }
}
