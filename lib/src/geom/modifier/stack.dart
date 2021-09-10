import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/dataflow/tuple.dart';

import 'modifier.dart';

class StackModifier extends Modifier {
  StackModifier({
    this.symmetric,
  });

  final bool? symmetric;

  @override
  bool operator ==(Object other) =>
    other is StackModifier &&
    super == other &&
    symmetric == other.symmetric;
}

class StackGeomModifier extends GeomModifier {
  StackGeomModifier(this.symmetric, this.normalZero);

  final bool symmetric;

  final double normalZero;

  /// Stack means every point in a position adds the top
  ///     point y of corresponding position of privior group.
  /// 
  /// To be meaningfull:
  ///     - For all groups, x must be same ordered discrete values.
  ///     - Y must be all positive or all negtive.
  /// 
  /// If symmetric, after stacking, the points will be re-distributed
  ///     symmetric to zero x line, keeping the relative distance.
  /// Symmetric is mostly used in river chart.
  @override
  void modify(AesGroups value) {
    for (var i = 1; i < value.length; i++) {
      final group = value[i];
      final preGroup = value[i - 1];
      for (var j = 0; j < group.length; j++) {
        final position = group[j].position;
        final prePosition = preGroup[j].position;

        var preTop = normalZero;
        for (var point in prePosition) {
          final y = point.dy;
          if (y.isFinite) {
            preTop = (preTop - normalZero).abs() >= (y - normalZero).abs() ? preTop : y;
          }
        }

        for (var k = 0; k < position.length; k++) {
          position[k] = Offset(
            position[k].dx,
            position[k].dy + (preTop - normalZero),
          );
        }
      }
    }

    if (symmetric) {
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
          aes.position = oldPosition.map(
            (point) => Offset(point.dx, point.dy + symmetricBias),
          ).toList();
        }
      }
    }
  }
}

class StackGeomModifierOp extends GeomModifierOp<StackGeomModifier> {
  StackGeomModifierOp(Map<String, dynamic> params) : super(params);

  @override
  StackGeomModifier evaluate() {
    final symmetric = params['symmetric'] as bool;
    final origin = params['origin'] as Offset;

    return StackGeomModifier(symmetric, origin.dy);
  }
}
