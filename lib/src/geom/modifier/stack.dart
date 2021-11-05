import 'dart:ui';

import 'package:graphic/src/dataflow/tuple.dart';

import 'modifier.dart';

/// The specification of a stack modifier.
///
/// The stack method cummulates elements in order of the values on a splitter.
/// It makes every point in a position adds the top point y of corresponding position
/// of the previous group.
///
/// To be meaningfull:
/// - For all groups, x must be of same ordered discrete values.
/// - Y values must be all positive or all negtive.
class StackModifier extends Modifier {
  @override
  bool operator ==(Object other) => other is StackModifier && super == other;
}

/// The stack geometory modifier.
class StackGeomModifier extends GeomModifier {
  StackGeomModifier(this.normalZero);

  /// The normal value of the stacked variable's zero.
  final double normalZero;

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
            preTop = (preTop - normalZero).abs() >= (y - normalZero).abs()
                ? preTop
                : y;
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
  }
}

/// The stack geometory modifier operator.
class StackGeomModifierOp extends GeomModifierOp<StackGeomModifier> {
  StackGeomModifierOp(Map<String, dynamic> params) : super(params);

  @override
  StackGeomModifier evaluate() {
    final origin = params['origin'] as Offset;

    return StackGeomModifier(origin.dy);
  }
}
