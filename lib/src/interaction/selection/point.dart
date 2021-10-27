import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'dart:ui';

import 'package:graphic/src/interaction/gesture.dart';

import 'selection.dart';

/// The selection to select discrete data values.
class PointSelection extends Selection {
  /// Creates a point selection.
  PointSelection({
    this.toggle,
    this.nearest,
    this.testRadius,
    int? dim,
    String? variable,
    Set<GestureType>? on,
    Set<GestureType>? clear,
  }) : super(
          dim: dim,
          variable: variable,
          on: on,
          clear: clear,
        );

  /// Whether triggered tuples should be toggled (inserted or removed from) or replace
  /// existing selected tuples.
  ///
  /// If null, a default false is set.
  bool? toggle;

  /// To select the tuple nearest to the pointer in the coordinate, Even if it's
  /// out of [testRadius].
  ///
  /// If null, a default true is set.
  bool? nearest;

  /// Radius of the pointer test.
  ///
  /// If null, a default 10 is set.
  double? testRadius;

  @override
  bool operator ==(Object other) =>
      other is PointSelection &&
      super == other &&
      toggle == other.toggle &&
      nearest == other.nearest &&
      testRadius == other.testRadius;
}

class PointSelector extends Selector {
  PointSelector(
    this.toggle,
    this.nearest,
    this.testRadius,
    String name,
    int? dim,
    String? variable,
    List<Offset> eventPoints, // [point]
  )   : assert(toggle != true || variable == null),
        super(
          name,
          dim,
          variable,
          eventPoints,
        );

  final bool toggle;

  final bool nearest;

  final double testRadius;

  @override
  Set<int>? select(
    AesGroups groups,
    List<Tuple> tuples,
    Set<int>? preSelects,
    CoordConv coord,
  ) {
    int nearestIndex = -1;
    double nearestDistance = double.infinity;
    void Function(Aes) updateNearest;

    final point = coord.invert(eventPoints.single);
    if (dim == null) {
      updateNearest = (aes) {
        final offset = aes.representPoint - point;
        final distance = (offset.dx.abs() + offset.dy.abs()) /
            2; // rect neighborhood for effecicy
        if (distance < nearestDistance) {
          nearestIndex = aes.index;
          nearestDistance = distance; // canvas
        }
      };
    } else {
      final getProjection = dim == 1
          ? (Offset offset) => offset.dx
          : (Offset offset) => offset.dy;
      updateNearest = (aes) {
        final p = aes.representPoint;
        final distance = (getProjection(point) - getProjection(p)).abs();
        if (distance < nearestDistance) {
          nearestIndex = aes.index;
          nearestDistance = distance; // canvas
        }
      };
    }

    for (var group in groups) {
      for (var aes in group) {
        updateNearest(aes);
      }
    }

    if (!nearest) {
      if (nearestDistance > coord.invertDistance(testRadius)) {
        return {};
      }
    }

    if (variable != null) {
      // Not toggle.
      final rst = <int>{};
      final value = tuples[nearestIndex][variable];
      for (var i = 0; i < tuples.length; i++) {
        if (tuples[i][variable] == value) {
          rst.add(i);
        }
      }
      return rst;
    }
    if (toggle && preSelects != null) {
      if (preSelects.contains(nearestIndex)) {
        return {...preSelects}..remove(nearestIndex);
      } else {
        return {...preSelects}..add(nearestIndex);
      }
    } else {
      return {nearestIndex};
    }
  }
}
