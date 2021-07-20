import 'dart:ui';
import 'dart:math';

import 'package:graphic/src/dataflow/pulse/pulse.dart';
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

class StackGeomModifier extends GeomModifer {
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
  void modify(List<List<Tuple>> value) {
    for (var i = 1; i < value.length; i++) {
      final group = value[i];
      final pregroup = value[i - 1];
      for (var j = 0; j < group.length; j++) {
        final position = group[j]['position'] as List<Offset>;
        final preposition = pregroup[j]['position'] as List<Offset>;

        var pretop = normalZero;
        for (var point in preposition) {
          final y = point.dy;
          if (y.isFinite) {
            pretop = (pretop - normalZero).abs() >= (y - normalZero).abs() ? pretop : y;
          }
        }

        for (var k = 0; k < position.length; k++) {
          position[k] = Offset(
            position[k].dx,
            position[k].dy + (pretop - normalZero),
          );
        }
      }
    }

    if (symmetric) {
      for (var i = 0; i < value.first.length; i++) {
        var minY = double.infinity;
        var maxY = double.negativeInfinity;
        for (var group in value) {
          final tuple = group[i];
          for (var point in (tuple['position'] as List<Offset>)) {
            final y = point.dy;
            if (y.isFinite) {
              minY = min(minY, y);
              maxY = max(maxY, y);
            }
          }
        }

        final symmetricBias = normalZero - (minY + maxY) / 2;
        for (var group in value) {
          final tuple = group[i];
          final oldPosition = tuple['position'] as List<Offset>;
          tuple['position'] = oldPosition.map(
            (point) => Offset(point.dx, point.dy + symmetricBias),
          ).toList();
        }
      }
    }
  }
}

class StackGeomModifierOp extends GeomModiferOp<StackGeomModifier> {
  StackGeomModifierOp(Map<String, dynamic> params) : super(params);

  @override
  StackGeomModifier update(Pulse pulse) {
    final symmetric = params['symmetric'] as bool;
    final origin = params['origin'] as Offset;

    return StackGeomModifier(symmetric, origin.dy);
  }
}
