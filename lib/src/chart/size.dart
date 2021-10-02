import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';

class ResizeEvent extends Event {
  ResizeEvent(this.size);

  @override
  EventType get type => EventType.resize;

  final Size size;
}

class SizeOp extends Value<Size> {
  SizeOp(Size value) : super(value);
}

void parseSize(
  Spec spec,
  View view,
  Scope scope,
) {
  scope.size = view.add(SizeOp(view.size));

  view.listen<ResizeEvent, Size>(
    view.sizeSouce,
    scope.size,
    (event) => event.size,
  );
}
