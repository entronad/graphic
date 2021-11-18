import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/interaction/signal.dart';

/// The signal emitted when chart size changes.
class ResizeSignal extends Signal {
  /// Creates a resize signal.
  ResizeSignal(this.size);

  @override
  SignalType get type => SignalType.resize;

  /// New size of chart.
  final Size size;
}

/// The chart size value operator.
class SizeOp extends Value<Size> {
  SizeOp(Size value) : super(value);
}
