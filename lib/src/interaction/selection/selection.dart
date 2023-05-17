import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/chart/chart_view.dart';
import 'package:graphic/src/common/dim.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/encode/encode.dart';
import 'package:graphic/src/graffiti/scene.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/util/collection.dart';

import 'interval.dart';
import 'point.dart';

/// The specification of a selection.
///
/// A selection is a data query driven by [Gesture]s. When a selection is triggered,
/// data tuples become either selected or unselected states(At least one tuple is
/// selected), thus may causing their aesthetic encodes change if [Encode.updaters]
/// is defined.
///
/// See also:
///
/// - [SelectionUpdater], updates an aesthetic encode value when the selection
/// state changes.
/// - [Encode.updaters], where selection updates are defined.
abstract class Selection {
  /// Creates a selection.
  Selection({
    this.dim,
    this.variable,
    this.on,
    this.clear,
    this.devices,
    this.layer,
  });

  /// Which diemsion of data values will be tested.
  ///
  /// If null, all dimensions will be tested.
  Dim? dim;

  /// If set, all tuples sharing the same this variable value with the selected
  /// tuple, will also be selected.
  String? variable;

  /// Gesture types that trigger this selection.
  ///
  /// Note that if multiple selections is declared, they can not have conflicting
  /// [on] gesture types.
  ///
  /// If null, a default `{GestureType.tap}` is set for [PointSelection].
  ///
  /// [IntervalSelection]'s [on] is fixed to `{GestureType.scaleUpdate, GestureType.scroll}`.
  Set<GestureType>? on;

  /// Gesture types that will clear selections.
  ///
  /// Note that any triggered [clear] type will clear any current selection, even
  /// if it's defined in another selection.
  ///
  /// If null, a default `{GestureType.doubleTap}` is set.
  Set<GestureType>? clear;

  /// The device kinds on which this selection is tiggered.
  ///
  /// If null, this selection will be triggered on all device kinds.
  Set<PointerDeviceKind>? devices;

  /// The layer of the selector mark.
  ///
  /// If null, a default 0 is set.
  int? layer;

  @override
  bool operator ==(Object other) =>
      other is Selection &&
      dim == other.dim &&
      variable == other.variable &&
      deepCollectionEquals(on, other.on) &&
      deepCollectionEquals(clear, other.clear) &&
      deepCollectionEquals(devices, other.devices) &&
      layer == other.layer;
}

/// Updates an easthetic encode value when the selection state of an mark
/// item changes.
///
/// You can define different selection updates for different selections and selection
/// states (See details in [Encode.updaters]).
///
/// The [initialValue] is the original item encode value (Set or calculated.).
///
/// Make sure the return value is a different instance from initialValue.
///
/// See also:
///
/// - [Encode.updaters], where selection updates are defined.
typedef SelectionUpdater<V> = V Function(V initialValue);

/// The base class of selectors.
///
/// A selector is defined by a [Selection] and triggerd by [GestureEvent]s. It
/// selects tuples in the select operator.
abstract class Selector {
  Selector(
    this.dim,
    this.variable,
    this.points,
  );

  /// Which diemsion of data values will be tested.
  final Dim? dim;

  /// If set, all tuples sharing the same this variable value with the selected
  /// tuple, will also be selected.
  final String? variable;

  /// The canvas points indicating the position of this selector.
  final List<Offset> points;

  /// Gets the selected tuple indexes.
  Set<int>? select(
    AttributesGroups groups,
    List<Tuple> tuples,
    Set<int>? preSelects,
    CoordConv coord,
  );
}

/// The operator to create selectors.
///
/// The value list is either null or not empty.
class SelectorOp extends Operator<Map<String, Selector>?> {
  SelectorOp(Map<String, dynamic> params) : super(params);

  @override
  bool get runInit => false;

  @override
  Map<String, Selector>? evaluate() {
    final specs = params['specs'] as Map<String, Selection>;
    final onTypes = params['onTypes'] as Map<GestureType, List<String>>;
    final clearTypes = params['clearTypes'] as Set<GestureType>;
    final gesture = params['gesture'] as Gesture?;

    if (gesture == null) {
      return value;
    }
    final type = gesture.type;
    final names = onTypes[type];
    if (clearTypes.contains(type)) {
      return null;
    }
    if (names == null) {
      return value;
    }

    final rst = <String, Selector>{};

    for (var name in names) {
      final spec = specs[name]!;
      if (spec.devices != null && !spec.devices!.contains(gesture.device)) {
        continue;
      }
      if (spec is PointSelection) {
        rst[name] = PointSelector(
          spec.toggle ?? false,
          spec.nearest ?? true,
          spec.testRadius ?? 10.0,
          spec.dim,
          spec.variable,
          [gesture.localPosition],
        );
      } else {
        spec as IntervalSelection;
        List<Offset> points;

        if (value != null && value!.keys.contains(name)) {
          // If an interval selector of the same name is in previous value.

          final prePoints = value![name]!.points;

          if (gesture.type == GestureType.scaleUpdate) {
            final detail = gesture.details as ScaleUpdateDetails;

            if (detail.pointerCount == 1) {
              if (gesture.localMoveStart == prePoints.first) {
                // Still in the creating panning.

                points = [gesture.localMoveStart!, gesture.localPosition];
              } else {
                // Pans to move.

                final delta = detail.focalPointDelta;
                points = [prePoints.first + delta, prePoints.last + delta];
              }
            } else {
              // Scales to zoom.

              final preScale = gesture.preScaleDetail!.scale;
              final scale = detail.scale;
              final deltaRatio = (scale - preScale) / preScale / 2;
              final preOffset = prePoints.last - prePoints.first;
              final delta = preOffset * deltaRatio;
              points = [prePoints.first - delta, prePoints.last + delta];
            }
          } else {
            // scrolls to zoom.

            const step = 0.1;
            final scrollDelta = gesture.details as Offset;
            final deltaRatio = scrollDelta.dy == 0
                ? 0.0
                : scrollDelta.dy > 0
                    ? (step / 2)
                    : (-step / 2);
            final preOffset = prePoints.last - prePoints.first;
            final delta = preOffset * deltaRatio;
            points = [prePoints.first - delta, prePoints.last + delta];
          }
        } else {
          // If the current interval selector is totally new.

          if (gesture.type == GestureType.scaleUpdate) {
            final detail = gesture.details as ScaleUpdateDetails;

            if (detail.pointerCount == 1) {
              // Only creates by panning.

              points = [gesture.localMoveStart!, gesture.localPosition];
            } else {
              return null;
            }
          } else {
            return null;
          }
        }

        rst[name] = IntervalSelector(
          spec.color ?? const Color(0x10101010),
          spec.dim,
          spec.variable,
          points,
        );
      }
    }
    return rst.isEmpty ? null : rst;
  }
}

/// The selector render operator.
///
/// Because the selectors may have different layeres, each defined selection has
/// an own scene and render operator, but the untriggered will has no elements.
class SelectorRenderOp extends Render {
  SelectorRenderOp(
    Map<String, dynamic> params,
    MarkScene scene,
    ChartView view,
  ) : super(params, scene, view);

  @override
  void render() {
    final selectors = params['selectors'] as Map<String, Selector>?;
    final name = params['name'] as String?;

    final selector = selectors?[name];

    if (selector is IntervalSelector) {
      scene.set(renderIntervalSelector(
        selector.points.first,
        selector.points.last,
        selector.color,
      ));
    } else {
      // The point selector has no mark for now.

      scene.set(null);
    }
  }
}

/// The result of selections of an mark.
///
/// The keys are selection names, and the values are selected datum indexes sets
/// of each selection.
typedef Selected = Map<String, Set<int>>;

/// The operator to select tuples by selectors.
class SelectOp extends Operator<Selected?> {
  SelectOp(Map<String, dynamic> params, Selected? value) : super(params, value);

  @override
  bool get runInit => false;

  @override
  Selected? evaluate() {
    final selectors = params['selectors'] as Map<String, Selector>?;
    final groups = params['groups'] as AttributesGroups;
    final tuples = params['tuples'] as List<Tuple>;
    final coord = params['coord'] as CoordConv;

    if (selectors == null) {
      return null;
    }

    final rst = <String, Set<int>>{};
    for (var name in selectors.keys) {
      final indexes = selectors[name]!.select(
        groups,
        tuples,
        value?[name],
        coord,
      );
      if (indexes != null) {
        // The Selector.select method has ensured indexes are not empty.
        rst[name] = indexes;
      }
    }
    return rst.isEmpty ? null : rst;
  }
}

/// Updates a value.
V? _update<V>(
  V? value,
  bool select,
  Map<bool, SelectionUpdater<V>>? updator,
) {
  if (value != null && updator != null) {
    final update = updator[select];
    if (update != null) {
      return update(value);
    }
  }
  return value;
}

/// The operator to update aesthetic encodes by selectors.
class SelectionUpdateOp extends Operator<AttributesGroups> {
  SelectionUpdateOp(Map<String, dynamic> params) : super(params);

  @override
  AttributesGroups evaluate() {
    final groups = params['groups'] as AttributesGroups;
    final selected = params['selected'] as Selected?;
    final shapeUpdaters = params['shapeUpdaters']
        as Map<String, Map<bool, SelectionUpdater<Shape>>>?;
    final colorUpdaters = params['colorUpdaters']
        as Map<String, Map<bool, SelectionUpdater<Color>>>?;
    final gradientUpdaters = params['gradientUpdaters']
        as Map<String, Map<bool, SelectionUpdater<Gradient>>>?;
    final elevationUpdaters = params['elevationUpdaters']
        as Map<String, Map<bool, SelectionUpdater<double>>>?;
    final labelUpdaters = params['labelUpdaters']
        as Map<String, Map<bool, SelectionUpdater<Label>>>?;
    final sizeUpdaters = params['sizeUpdaters']
        as Map<String, Map<bool, SelectionUpdater<double>>>?;
    final updaterNames = params['updaterNames'] as Set<String>;

    // Makes sure only one selects result works.
    final name = singleIntersection(selected?.keys, updaterNames);

    if (name == null) {
      return groups.map((group) => [...group]).toList();
    }

    final selects = selected![name]!;
    // Internal selected indexes will never be empty, this is for user set or emitted
    // selects.
    assert(selects.isNotEmpty);

    final shapeUpdater = shapeUpdaters?[name];
    final colorUpdater = colorUpdaters?[name];
    final gradientUpdater = gradientUpdaters?[name];
    final elevationUpdater = elevationUpdaters?[name];
    final labelUpdater = labelUpdaters?[name];
    final sizeUpdater = sizeUpdaters?[name];

    if (shapeUpdater == null &&
        colorUpdater == null &&
        gradientUpdater == null &&
        elevationUpdater == null &&
        labelUpdater == null &&
        sizeUpdater == null) {
      return groups.map((group) => [...group]).toList();
    }

    final rst = <List<Attributes>>[];
    for (var group in groups) {
      final groupRst = <Attributes>[];
      for (var i = 0; i < group.length; i++) {
        final attributes = group[i];
        final isSelected = selects.contains(attributes.index);
        groupRst.add(Attributes(
          index: attributes.index,
          position: [...attributes.position],
          shape: _update(attributes.shape, isSelected, shapeUpdater)!,
          color: _update(attributes.color, isSelected, colorUpdater),
          gradient: _update(attributes.gradient, isSelected, gradientUpdater),
          elevation:
              _update(attributes.elevation, isSelected, elevationUpdater),
          label: _update(attributes.label, isSelected, labelUpdater),
          size: _update(attributes.size, isSelected, sizeUpdater),
        ));
      }
      rst.add(groupRst);
    }
    return rst;
  }
}
