import 'dart:ui';

import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/scale.dart';

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
  bool equalTo(Object other) => other is StackModifier;

  @override
  void modify(AesGroups groups, Map<String, ScaleConv<dynamic, num>> scales,
      AlgForm form, CoordConv coord, Offset origin) {
    final normalZero = origin.dy;

    for (var i = 1; i < groups.length; i++) {
      final group = groups[i];
      final preGroup = groups[i - 1];
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
