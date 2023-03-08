import 'package:graphic/src/common/dim.dart';
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
    Dim? dim,
    String? variable,
    Set<GestureType>? on,
    Set<GestureType>? clear,
    Set<PointerDeviceKind>? devices,
    int? layer,
  }) : super(
          dim: dim,
          variable: variable,
          on: on,
          clear: clear,
          devices: devices,
          layer: layer,
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

/// The point selector.
///
/// The [points] have only one point.
class PointSelector extends Selector {
  PointSelector(
    this.toggle,
    this.nearest,
    this.testRadius,
    Dim? dim,
    String? variable,
    List<Offset> points,
  )   : assert(toggle != true || variable == null),
        super(
          dim,
          variable,
          points,
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
    // nearestDistance is a canvas distance.
    double nearestDistance = double.infinity;
    void Function(Attributes) updateNearest;

    final point = coord.invert(points.single);
    if (dim == null) {
      updateNearest = (attributes) {
        final offset = attributes.representPoint - point;
        // The neighborhood is an approximate square.
        final distance = (offset.dx.abs() + offset.dy.abs()) / 2;
        if (distance < nearestDistance) {
          nearestIndex = attributes.index;
          nearestDistance = distance;
        }
      };
    } else {
      final getProjection = dim == Dim.x
          ? (Offset offset) => offset.dx
          : (Offset offset) => offset.dy;
      updateNearest = (attributes) {
        final p = attributes.representPoint;
        final distance = (getProjection(point) - getProjection(p)).abs();
        if (distance < nearestDistance) {
          nearestIndex = attributes.index;
          nearestDistance = distance;
        }
      };
    }

    for (var group in groups) {
      for (var attributes in group) {
        updateNearest(attributes);
      }
    }

    if (!nearest) {
      if (nearestDistance > coord.invertDistance(testRadius)) {
        return null;
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
      return rst.isEmpty ? null : rst;
    }

    Set<int> rst;
    if (toggle && preSelects != null) {
      if (preSelects.contains(nearestIndex)) {
        rst = {...preSelects}..remove(nearestIndex);
      } else {
        rst = {...preSelects}..add(nearestIndex);
      }
    } else {
      rst = {nearestIndex};
    }
    return rst.isEmpty ? null : rst;
  }
}
