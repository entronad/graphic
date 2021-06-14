import 'dart:ui';

import 'package:flutter/painting.dart';

import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/util/assert.dart';

class Tick extends Spec {
  Tick({
    this.style,
    this.length,
  });

  final StrokeStyle? style;

  final double? length;
}

class AxisLabel extends Spec {
  AxisLabel({
    this.style,
    this.offset,
    this.rotation,
  });

  final TextStyle? style;

  final Offset? offset;

  final double? rotation;
}

class Axis extends Spec {
  Axis({
    this.dim,
    this.variables,
    this.tickCount,
    this.nice,
    this.postion,
    this.flip,
    this.line,
    this.tick,
    this.grid,
    this.gridCallback,
    this.label,
    this.labelCallback,
  })
    : assert(isSingle([grid, gridCallback], allowNone: true)),
      assert(isSingle([label, labelCallback], allowNone: true));

  final int? dim;

  final List<String>? variables;

  final int? tickCount; // Max tick count.

  final bool? nice;

  final double? postion;

  final bool? flip;  // Flip tick and label to other side of the axis.

  final StrokeStyle? line;

  final Tick? tick;

  final StrokeStyle? grid;

  final StrokeStyle Function(String text, int index, int total)? gridCallback;

  final AxisLabel? label;

  final AxisLabel Function(String text, int index, int total)? labelCallback;
}
