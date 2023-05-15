import 'dart:ui';

import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/scale.dart';

import 'modifier.dart';

/// The specification of a stack modifier.
///
/// The stack method cummulates marks in order of the values on a splitter.
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
  AttributesGroups modify(
      AttributesGroups groups,
      Map<String, ScaleConv<dynamic, num>> scales,
      AlgForm form,
      CoordConv coord,
      Offset origin) {
    final normalZero = origin.dy;

    // The first group need no change.
    final AttributesGroups rst = [groups.first];
    for (var i = 1; i < groups.length; i++) {
      final group = groups[i];
      // The stacking is accumulative, so refers to the pre one from rst.
      final preGroup = rst[i - 1];
      final groupRst = <Attributes>[];
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

        groupRst.add(group[j].withPosition(position
            .map((point) => Offset(
                  point.dx,
                  point.dy + (preTop - normalZero),
                ))
            .toList()));
      }
      rst.add(groupRst);
    }

    return rst;
  }
}
