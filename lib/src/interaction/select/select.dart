import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/common/layers.dart';
import 'package:graphic/src/common/operators/render.dart';
import 'package:graphic/src/coord/coord.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/interaction/gesture/gesture.dart';
import 'package:graphic/src/graffiti/graffiti.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:collection/collection.dart';
import 'package:graphic/src/interaction/event.dart';

import 'interval.dart';
import 'point.dart';

typedef SelectUpdate<V> = V Function(V initialValue);

abstract class Select {
  Select({
    this.dim,
    this.variable,
    this.on,
    this.clear,
  });

  final int? dim;

  final String? variable;

  final Set<EventType>? on;

  final Set<EventType>? clear;

  @override
  bool operator ==(Object other) =>
    other is Select &&
    dim == other.dim &&
    variable == other.variable &&
    DeepCollectionEquality().equals(on, other.on) &&
    DeepCollectionEquality().equals(clear, other.clear);
}

// selector

abstract class Selector {
  Selector(
    this.name,
    this.dim,
    this.variable,
    this.eventPoints,
  );

  final String name;

  final int? dim;

  final String? variable;

  final List<Offset> eventPoints;

  Set<int>? select(
    AesGroups groups,
    List<Original> originals,
    Set<int>? preSelects,
    CoordConv coord,
  );
}

class SelectorOp extends Operator<Selector?> {
  SelectorOp(Map<String, dynamic> params) : super(params);

  @override
  Selector? evaluate() {
    final specs = params['specs'] as Map<String, Select>;
    final onTypes = params['selectors'] as Map<EventType, String>;
    final offTypes = params['offTypes'] as Set<EventType>;
    final event = params['event'] as GestureEvent?;

    if (event == null) {
      return value;
    }
    final type = event.type;
    final name = onTypes[type];
    if (offTypes.contains(type)) {
      return null;
    }
    if (name == null) {
      return value;
    }
    final spec = specs[onTypes[type]]!;
    if (spec is PointSelect) {
      return PointSelector(
        spec.toggle ?? false,  // TODO: defalut
        spec.nearest ?? true,  // TODO: defalut
        spec.testRadius ?? 5,  // TODO: defalut
        name,
        spec.dim,
        spec.variable,
        [event.pointerEvent.position],
      );
    } else {
      spec as IntervalSelect;
      List<Offset> eventPoints;
      if (type == EventType.scaleUpdate) {
        eventPoints = [event.scale!.focalPoint, event.pointerEvent.position];
      } else { // panUpdate
        if (value is IntervalSelector) {
          final delta = event.pointerEvent.delta;
          eventPoints = value!.eventPoints
            .map((point) => point + delta)
            .toList();
        } else {
          return value;
        }
      }
      return IntervalSelector(
        spec.color ?? Color(0x10101010),  // TODO: defalut
        spec.zIndex ?? 0,  // TODO: defalut
        name,
        spec.dim,
        spec.variable,
        eventPoints,
      );
    }
  }
}

abstract class SelectorPainter extends Painter {}

class SelecorScene extends Scene {
  @override
  int get layer => Layers.selector;
}

class SelectorRenderOp extends Render<SelecorScene> {
  SelectorRenderOp(
    Map<String, dynamic> params,
    SelecorScene scene,
  ) : super(params, scene);

  @override
  void render() {
    final selector = params['selector'] as Selector?;

    if (selector is IntervalSelector) {
      scene
        ..zIndex = selector.zIndex
        ..painter = IntervalSelectorPainter(
            selector.eventPoints.first,
            selector.eventPoints.last,
            selector.color,
          );
    }
  }
}

// select

/// Can be preseted.
class SelectOp extends Operator<Set<int>?> {
  SelectOp(
    Map<String, dynamic> params,
    Set<int>? value
  ) : super(params, value);

  @override
  Set<int>? evaluate() {
    final selector = params['selector'] as Selector?;
    final groups = params['groups'] as AesGroups;
    final originals = params['originals'] as List<Original>;
    final coord = params['coord'] as CoordConv;

    if (selector == null) {
      return null;
    } else {
      return selector.select(
        groups,
        originals,
        value,
        coord,
      );
    }
  }
}

// update

V? _update<V>(
  V? value,
  bool select,
  Map<bool, SelectUpdate<V>>? updator,
) {
  if (value != null && updator != null) {
    final update = updator[select];
    if (update != null) {
      return update(value);
    }
  }
  return value;
}

/// It is still in the aes scope so share the same aeses instance.
class ElementUpdateOp extends Operator<AesGroups> {
  ElementUpdateOp(Map<String, dynamic> params) : super(params);

  @override
  AesGroups evaluate() {
    final groups = params['groups'] as AesGroups;
    final selects = params['selects'] as Set<int>?;
    final shapeUpdater = params['shapeUpdater'] as Map<bool, SelectUpdate<Shape>>?;
    final colorUpdater = params['colorUpdater'] as Map<bool, SelectUpdate<Color>>?;
    final gradientUpdater = params['gradientUpdater'] as Map<bool, SelectUpdate<Gradient>>?;
    final elevationUpdater = params['elevationUpdater'] as Map<bool, SelectUpdate<double>>?;
    final labelUpdater = params['labelUpdater'] as Map<bool, SelectUpdate<Label>>?;
    final sizeUpdater = params['sizeUpdater'] as Map<bool, SelectUpdate<double>>?;

    if (selects == null || (
      shapeUpdater == null &&
      colorUpdater == null &&
      gradientUpdater == null &&
      elevationUpdater == null &&
      labelUpdater == null &&
      sizeUpdater == null
    )) {
      return groups
        .map((group) => [...group])
        .toList();
    }

    final rst = <List<Aes>>[];
    for (var group in groups) {
      final groupRst = <Aes>[];
      for (var i = 0; i < group.length; i++) {
        final aes = group[i];
        final selected = selects.contains(aes.index);
        groupRst[i] = Aes(
          index: aes.index,
          position: [...aes.position],
          shape: _update(aes.shape, selected, shapeUpdater)!,
          color: _update(aes.color, selected, colorUpdater),
          gradient: _update(aes.gradient, selected, gradientUpdater),
          elevation: _update(aes.elevation, selected, elevationUpdater),
          label: _update(aes.label, selected, labelUpdater),
          size: _update(aes.size, selected, sizeUpdater),
        );
      }
    }
    return rst;
  }
}
