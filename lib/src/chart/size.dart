import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/dataflow/operator.dart';
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

/// The chart size operator.
class SizeOp extends Operator<Size> {
  SizeOp(
    Map<String, dynamic> params,
    Size value,
  ) : super(params, value);

  @override
  bool get runInit => false;

  @override
  Size evaluate() {
    final signal = params['signal'] as ResizeSignal;
    return signal.size;
  }
}
