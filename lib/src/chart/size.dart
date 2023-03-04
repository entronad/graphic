import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/interaction/event.dart';

/// The event emitted when chart size changes.
class ResizeEvent extends Event {
  /// Creates a resize event.
  ResizeEvent(this.size);

  @override
  EventType get type => EventType.resize;

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
    final event = params['event'] as ResizeEvent;
    return event.size;
  }
}
