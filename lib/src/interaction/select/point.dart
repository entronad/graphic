import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'dart:ui';

import 'package:graphic/src/interaction/gesture/arena.dart';

import 'select.dart';

class PointSelect extends Select {
  PointSelect({
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

  final bool? toggle;

  final bool? nearest;

  final double? testRadius;

  @override
  bool operator ==(Object other) =>
    other is PointSelect &&
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
    List<Offset> eventPoints,  // [point]
  )
    : assert(toggle != true || variable == null),
      assert(dim == null || nearest),
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
    List<Original> originals,
    Set<int>? preSelects,
    CoordConv coord,
  ) {
    final canvasPoint = eventPoints.first;

    int nearestIndex = -1;
    double nearestDistance = double.infinity;  // May be abstarct or canvas in different circumstances.
    void Function(Aes) updateNearest;
    if (dim == null) {
      updateNearest = (aes) {
        final p = aes.representPoint;
        final canvasP = coord.convert(p);
        final distance = (canvasPoint - canvasP).distance;
        if (distance < nearestDistance) {
          nearestIndex = aes.index;
          nearestDistance = distance;  // canvas
        }
      };
    } else {
      final point = coord.invert(canvasPoint);
      final getProjection = dim == 1
        ? (Offset offset) => offset.dx
        : (Offset offset) => offset.dy;
      updateNearest = (aes) {
        final p = aes.representPoint;
        final distance = (getProjection(point) - getProjection(p)).abs();
        if (distance < nearestDistance) {
          nearestIndex = aes.index;
          nearestDistance = distance;  // canvas
        }
      };
    }

    for (var group in groups) {
      for (var aes in group) {
        updateNearest(aes);
      }
    }

    if (!nearest) {
      if (nearestDistance > testRadius) {
        return null;
      }
    }

    if (variable != null) {  // Not toggle.
      final rst = <int>{};
      final value = originals[nearestIndex][variable];
      for (var i = 0; i < originals.length; i++) {
        if (originals[i][variable] == value) {
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
