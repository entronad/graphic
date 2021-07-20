import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/painting.dart';
import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/util/assert.dart';

class Tick {
  Tick({
    this.style,
    this.length,
  });

  final StrokeStyle? style;

  final double? length;

  @override
  bool operator ==(Object other) =>
    other is Tick &&
    style == other.style &&
    length == other.length;
}

class AxisLabel {
  AxisLabel({
    this.style,
    this.offset,
    this.rotation,
  });

  final TextStyle? style;

  final Offset? offset;

  final double? rotation;

  @override
  bool operator ==(Object other) =>
    other is AxisLabel &&
    style == other.style &&
    offset == other.offset &&
    rotation == other.rotation;
}

class GuideAxis {
  GuideAxis({
    this.dim,
    this.variables,
    this.tickCount,
    this.nice,
    this.position,
    this.flip,
    this.line,
    this.tick,
    this.grid,
    this.gridMapper,
    this.label,
    this.labelMapper,
    this.zIndex,
    this.gridZIndex,
  })
    : assert(isSingle([grid, gridMapper], allowNone: true)),
      assert(isSingle([label, labelMapper], allowNone: true));

  final int? dim;

  final List<String>? variables;

  final int? tickCount; // Max tick count.

  final bool? nice;

  final double? position;

  final bool? flip;  // Flip tick and label to other side of the axis.

  final StrokeStyle? line;

  final Tick? tick;

  final StrokeStyle? grid;

  final StrokeStyle Function(String text, int index, int total)? gridMapper;

  final AxisLabel? label;

  final AxisLabel Function(String text, int index, int total)? labelMapper;

  final int? zIndex;

  final int? gridZIndex;

  @override
  bool operator ==(Object other) =>
    other is GuideAxis &&
    dim == other.dim &&
    DeepCollectionEquality().equals(variables, other.variables) &&
    tickCount == other.tickCount &&
    nice == other.nice &&
    position == other.position &&
    flip == other.flip &&
    line == other.line &&
    tick == other.tick &&
    grid == other.grid &&
    // gridMapper: Function
    label == other.label &&
    // labelMapper: Function
    zIndex == other.zIndex &&
    gridZIndex == other.gridZIndex;
}
