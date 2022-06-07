import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/aes/aes.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/dim.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/intrinsic_layers.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/geom/element.dart';
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
/// selected), thus may causing their aesthetic attributes change if [Attr.onSelection]
/// is defined.
///
/// See also:
///
/// - [SelectionUpdater], updates an aesthetic attribute value when the selection
/// state changes.
/// - [Attr.onSelection], where selection updates are defined.
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

/// Updates an easthetic attribute value when the selection state of an element
/// item changes.
///
/// You can define different selection updates for different selections and selection
/// states (See details in [Attr.onSelection]).
///
/// The [initialValue] is the original item attribute value (Set or calculated.).
///
/// Make sure the return value is a different instance from initialValue.
///
/// See also:
///
/// - [Attr.onSelection], where selection updates are defined.
typedef SelectionUpdater<V> = V Function(V initialValue);

/// The base class of selectors.
///
/// A selector is defined by a [Selection] and triggerd by [GestureSignal]s. It
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
    AesGroups groups,
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

            final step = 0.1;
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
          spec.color ?? Color(0x10101010),
          spec.dim,
          spec.variable,
          points,
        );
      }
    }
    return rst.isEmpty ? null : rst;
  }
}

/// The selector scene.
class SelectorScene extends Scene {
  SelectorScene(int layer) : super(layer);

  @override
  int get intrinsicLayer => IntrinsicLayers.selector;
}

/// The selector render operator.
///
/// Because the selectors may have different layeres, each defined selection has
/// an own scene and render operator, but the untriggered will has no figures.
class SelectorRenderOp extends Render<SelectorScene> {
  SelectorRenderOp(
    Map<String, dynamic> params,
    SelectorScene scene,
    View view,
  ) : super(params, scene, view);

  @override
  void render() {
    final selectors = params['selectors'] as Map<String, Selector>?;
    final name = params['name'] as String?;

    final selector = selectors?[name];

    if (selector is IntervalSelector) {
      scene
        ..figures = renderIntervalSelector(
          selector.points.first,
          selector.points.last,
          selector.color,
        );
    } else {
      // The point selector has no mark for now.

      scene.figures = null;
    }
  }
}

/// The result of selections of an element.
///
/// The keys are selection names, and the values are selected datum indexes sets
/// of each selection.
typedef Selected = Map<String, Set<int>>;

/// The operator to select tuples by selectors.
class SelectOp extends Operator<Selected?> {
  SelectOp(Map<String, dynamic> params, Selected? value) : super(params, value);

  /// Whether it is in initialization when [evaluate].
  ///
  /// It will keep true until the first selector occurs.
  ///
  /// The state of selected is totally determined by the state of selectors. So
  /// the initial status when there is no selectors yet should be indicated by this
  /// property to handle [GeomElement.selected].
  bool inInit = true;

  @override
  Selected? evaluate() {
    final selectors = params['selectors'] as Map<String, Selector>?;
    final groups = params['groups'] as AesGroups;
    final tuples = params['tuples'] as List<Tuple>;
    final coord = params['coord'] as CoordConv;

    if (selectors == null) {
      // Returns pre-selected in init.
      return inInit ? value : null;
    }

    if (inInit) {
      // Shifts when first selector executes.
      inInit = false;
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

/// The operator to update aesthetic attributes by selectors.
class SelectionUpdateOp extends Operator<AesGroups> {
  SelectionUpdateOp(Map<String, dynamic> params) : super(params);

  @override
  AesGroups evaluate() {
    final groups = params['groups'] as AesGroups;
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

    final rst = <List<Aes>>[];
    for (var group in groups) {
      final groupRst = <Aes>[];
      for (var i = 0; i < group.length; i++) {
        final aes = group[i];
        final isSelected = selects.contains(aes.index);
        groupRst.add(Aes(
          index: aes.index,
          position: [...aes.position],
          shape: _update(aes.shape, isSelected, shapeUpdater)!,
          color: _update(aes.color, isSelected, colorUpdater),
          gradient: _update(aes.gradient, isSelected, gradientUpdater),
          elevation: _update(aes.elevation, isSelected, elevationUpdater),
          label: _update(aes.label, isSelected, labelUpdater),
          size: _update(aes.size, isSelected, sizeUpdater),
        ));
      }
      rst.add(groupRst);
    }
    return rst;
  }
}
