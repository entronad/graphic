import 'dart:math';
import 'dart:ui';

import 'package:graphic/src/algebra/varset.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/scale.dart';

import 'modifier.dart';

/// The specification of a symmetric modifier.
///
/// The symmetric method redistributes all position points symmetricly around the
/// zero, keeping their relative position unchanged.
///
/// It is mostly used in river chart, and funnel chart.
class SymmetricModifier extends Modifier {
  @override
  bool operator ==(Object other) => other is SymmetricModifier;

  @override
  bool equalTo(Object other) => other is SymmetricModifier && super == other;

  @override
  AttributesGroups modify(
      AttributesGroups groups,
      Map<String, ScaleConv<dynamic, num>> scales,
      AlgForm form,
      CoordConv coord,
      Offset origin) {
    final normalZero = origin.dy;

    final AttributesGroups rst = groups.map((_) => <Attributes>[]).toList();
    for (var i = 0; i < groups.first.length; i++) {
      var minY = double.infinity;
      var maxY = double.negativeInfinity;
      for (var group in groups) {
        final attributes = group[i];
        for (var point in attributes.position) {
          final y = point.dy;
          if (y.isFinite) {
            minY = min(minY, y);
            maxY = max(maxY, y);
          }
        }
      }

      final symmetricBias = normalZero - (minY + maxY) / 2;
      for (var j = 0; j < groups.length; j++) {
        final attributes = groups[j][i];
        final oldPosition = attributes.position;
        rst[j].add(attributes.withPosition(oldPosition
          .map(
            (point) => Offset(point.dx, point.dy + symmetricBias),
          )
          .toList()));
      }
    }

    return rst;
  }
}
