import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';

import 'event.dart';

enum GestureType {
  tap,
  tapCancel,
  tapDown,
  tapUp,
  doubleTap,
  doubleTapCancel,
  doubleTapDown,
  scaleEnd,
  scaleStart,
  scaleUpdate,
  longPress,
  longPressCancel,
  longPressDown,
  longPressEnd,
  longPressMoveUpdate,
  longPressStart,
  longPressUp,

  forcePressEnd,
  forcePressPeak,
  forcePressStart,
  forcePressUpdate,
  secondaryLongPress,
  secondaryLongPressCancel,
  secondaryLongPressDown,
  secondaryLongPressEnd,
  secondaryLongPressMoveUpdate,
  secondaryLongPressStart,
  secondaryLongPressUp,
  secondaryTap,
  secondaryTapCancel,
  secondaryTapDown,
  secondaryTapUp,
  tertiaryLongPress,
  tertiaryLongPressCancel,
  tertiaryLongPressDown,
  tertiaryLongPressEnd,
  tertiaryLongPressMoveUpdate,
  tertiaryLongPressStart,
  tertiaryLongPressUp,
  tertiaryTapCancel,
  tertiaryTapDown,
  tertiaryTapUp,

  hover,
  scroll,
}

class Gesture {
  Gesture(
    this.type,
    this.kink,
    this.localPosition,
    this.chartSize,
    this.detail,
    {this.localMoveStart,
    this.preScaleDetail,}
  );

  final GestureType type;

  final PointerDeviceKind kink;

  final Offset localPosition;

  final Size chartSize;

  final dynamic detail;

  final Offset? localMoveStart;

  // By hacking the scale start, Scale update always has it.
  final ScaleUpdateDetails? preScaleDetail;
}

class GestureEvent extends Event {
  GestureEvent(this.gesture);

  @override
  EventType get type => EventType.gesture;

  final Gesture gesture;
}

class GestureOp extends Value<Gesture?> {
  @override
  bool get consume => true;
}

void parseGesture(
  Spec spec,
  View view,
  Scope scope,
) {
  scope.gesture = view.add(GestureOp());

  view.listen<GestureEvent, Gesture?>(
    view.gestureSource,
    scope.gesture,
    (event) => event.gesture,
  );
}
