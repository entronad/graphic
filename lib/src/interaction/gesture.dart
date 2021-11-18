import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:graphic/src/common/operators/value.dart';

import 'signal.dart';

/// Types of [Gesture]s.
///
/// A chart can responses to gesture types the same as [GestureDetector], except
/// that pan series, horizontal drag series and vertical drag series are uniformed
/// into scale series.
///
/// Besides, a [hover] type and a [scroll] type is defined for mouse interactions.
///
/// See also:
///
/// - [GestureDetector], which detects gestures.
/// - [Listener], which responses to common pointer events that compose [hover]
/// and [scroll] gestures.
enum GestureType {
  /// A tap with a primary button has occurred.
  ///
  /// This triggers when the tap gesture wins. If the tap gesture did not win,
  /// [tapCancel] is emitted instead.
  ///
  /// A gesture of this type has no detail.
  tap,

  /// The pointer that previously triggered [tapDown] will not end up causing
  /// a tap.
  ///
  /// This is emitted after [tapDown], and instead of [tapUp] and [tap], if
  /// the tap gesture did not win.
  ///
  /// A gesture of this type has no detail.
  tapCancel,

  /// A pointer that might cause a tap with a primary button has contacted the
  /// screen at a particular location.
  ///
  /// This is emitted after a short timeout, even if the winning gesture has not
  /// yet been selected. If the tap gesture wins, [tapUp] will be emitted,
  /// otherwise [tapCancel] will be emitted.
  ///
  /// A gesture of this type has details of [TapDownDetails].
  tapDown,

  /// A pointer that will trigger a tap with a primary button has stopped
  /// contacting the screen at a particular location.
  ///
  /// This triggers immediately before [tap] in the case of the tap gesture
  /// winning. If the tap gesture did not win, [tapCancel] is emitted instead.
  ///
  /// A gesture of this type has details of [TapUpDetails].
  tapUp,

  /// The user has tapped the screen with a primary button at the same location
  /// twice in quick succession.
  ///
  /// A gesture of this type has no detail.
  doubleTap,

  /// The pointer that previously triggered [doubleTapDown] will not end up
  /// causing a double tap.
  ///
  /// A gesture of this type has no detail.
  doubleTapCancel,

  /// A pointer that might cause a double tap has contacted the screen at a
  /// particular location.
  ///
  /// Triggered immediately after the down gesture of the second tap.
  ///
  /// If the user completes the double tap and the gesture wins, [doubleTap]
  /// will be emitted after this gesture. Otherwise, [doubleTapCancel] will
  /// be emitted after this gesture.
  ///
  /// A gesture of this type has details of [TapDownDetails].
  doubleTapDown,

  /// The pointers are no longer in contact with the screen.
  ///
  /// A gesture of this type has details of [ScaleEndDetails].
  scaleEnd,

  /// The pointers in contact with the screen have established a focal point and
  /// initial scale of 1.0.
  ///
  /// A gesture of this type has details of [ScaleStartDetails].
  scaleStart,

  /// The pointers in contact with the screen have indicated a new focal point
  /// and/or scale.
  ///
  /// A gesture of this type has details of [ScaleUpdateDetails].
  scaleUpdate,

  /// Called when a long press gesture with a primary button has been recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is emitted immediately after) [longPressStart].
  /// The only difference between the two is that this gesture does not
  /// contain details of the position at which the pointer initially contacted
  /// the screen.
  ///
  /// A gesture of this type has no details.
  longPress,

  /// A pointer that previously triggered [longPressDown] will not end up
  /// causing a long-press.
  ///
  /// This triggers once the gesture loses if [longPressDown] has previously
  /// been triggered.
  ///
  /// If the user completed the long-press, and the gesture won, then
  /// [longPressStart] and [longPress] are emitted instead.
  ///
  /// A gesture of this type has no details.
  longPressCancel,

  /// The pointer has contacted the screen with a primary button, which might
  /// be the start of a long-press.
  ///
  /// This triggers after the pointer down gesture.
  ///
  /// If the user completes the long-press, and this gesture wins,
  /// [longPressStart] will be emitted after this gesture. Otherwise,
  /// [longPressCancel] will be emitted after this gesture.
  ///
  /// A gesture of this type has details of [LongPressDownDetails].
  longPressDown,

  /// A pointer that has triggered a long-press with a primary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is emitted immediately before) [longPressUp].
  /// The only difference between the two is that this gesture contains
  /// details of the state of the pointer when it stopped contacting the
  /// screen, whereas [longPressUp] does not.
  ///
  /// A gesture of this type has details of [LongPressEndDetails].
  longPressEnd,

  /// A pointer has been drag-moved after a long-press with a primary button.
  ///
  /// A gesture of this type has details of [LongPressMoveUpdateDetails].
  longPressMoveUpdate,

  /// Called when a long press gesture with a primary button has been recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is emitted immediately before) [longPress].
  /// The only difference between the two is that this gesture contains
  /// details of the position at which the pointer initially contacted the
  /// screen, whereas [longPress] does not.
  ///
  /// A gesture of this type has details of [LongPressStartDetails].
  longPressStart,

  /// A pointer that has triggered a long-press with a primary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is emitted immediately after) [longPressEnd].
  /// The only difference between the two is that this gesture does not
  /// contain details of the state of the pointer when it stopped contacting
  /// the screen.
  ///
  /// A gesture of this type has no details.
  longPressUp,

  /// The pointer is no longer in contact with the screen.
  ///
  /// Note that this gesture will only be fired on devices with pressure
  /// detecting screens.
  ///
  /// A gesture of this type has details of [ForcePressDetails].
  forcePressEnd,

  /// The pointer is in contact with the screen and has pressed with the maximum
  /// force. The amount of force is at least
  /// [ForcePressGestureRecognizer.peakPressure].
  ///
  /// Note that this gesture will only be fired on devices with pressure
  /// detecting screens.
  ///
  /// A gesture of this type has details of [ForcePressDetails].
  forcePressPeak,

  /// The pointer is in contact with the screen and has pressed with sufficient
  /// force to initiate a force press. The amount of force is at least
  /// [ForcePressGestureRecognizer.startPressure].
  ///
  /// Note that this gesture will only be fired on devices with pressure
  /// detecting screens.
  ///
  /// A gesture of this type has details of [ForcePressDetails].
  forcePressStart,

  /// A pointer is in contact with the screen, has previously passed the
  /// [ForcePressGestureRecognizer.startPressure] and is either moving on the
  /// plane of the screen, pressing the screen with varying forces or both
  /// simultaneously.
  ///
  /// Note that this gesture will only be fired on devices with pressure
  /// detecting screens.
  ///
  /// A gesture of this type has details of [ForcePressDetails].
  forcePressUpdate,

  /// Called when a long press gesture with a secondary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is emitted immediately after)
  /// [secondaryLongPressStart]. The only difference between the two is that
  /// this gesture does not contain details of the position at which the
  /// pointer initially contacted the screen.
  ///
  /// A gesture of this type has no details.
  secondaryLongPress,

  /// A pointer that previously triggered [secondaryLongPressDown] will not
  /// end up causing a long-press.
  ///
  /// This triggers once the gesture loses if [secondaryLongPressDown] has
  /// previously been triggered.
  ///
  /// If the user completed the long-press, and the gesture won, then
  /// [secondaryLongPressStart] and [secondaryLongPress] are emitted instead.
  ///
  /// A gesture of this type has no details.
  secondaryLongPressCancel,

  /// The pointer has contacted the screen with a secondary button, which might
  /// be the start of a long-press.
  ///
  /// This triggers after the pointer down gesture.
  ///
  /// If the user completes the long-press, and this gesture wins,
  /// [secondaryLongPressStart] will be emitted after this gesture. Otherwise,
  /// [secondaryLongPressCancel] will be emitted after this gesture.
  ///
  /// A gesture of this type has details of [LongPressDownDetails].
  secondaryLongPressDown,

  /// A pointer that has triggered a long-press with a primary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is emitted immediately before) [longPressUp].
  /// The only difference between the two is that this gesture contains
  /// details of the state of the pointer when it stopped contacting the
  /// screen, whereas [longPressUp] does not.
  ///
  /// A gesture of this type has details of [LongPressEndDetails].
  secondaryLongPressEnd,

  /// A pointer has been drag-moved after a long press with a secondary button.
  ///
  /// A gesture of this type has details of [LongPressMoveUpdateDetails].
  secondaryLongPressMoveUpdate,

  /// Called when a long press gesture with a secondary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is emitted immediately before)
  /// [secondaryLongPress]. The only difference between the two is that this
  /// gesture contains details of the position at which the pointer initially
  /// contacted the screen, whereas [secondaryLongPress] does not.
  ///
  /// A gesture of this type has details of [LongPressStartDetails].
  secondaryLongPressStart,

  /// A pointer that has triggered a long-press with a secondary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is emitted immediately after)
  /// [secondaryLongPressEnd]. The only difference between the two is that
  /// this gesture does not contain details of the state of the pointer when
  /// it stopped contacting the screen.
  ///
  /// A gesture of this type has no details.
  secondaryLongPressUp,

  /// A tap with a secondary button has occurred.
  ///
  /// This triggers when the tap gesture wins. If the tap gesture did not win,
  /// [secondaryTapCancel] is emitted instead.
  ///
  /// A gesture of this type has no details.
  secondaryTap,

  /// The pointer that previously triggered [secondaryTapDown] will not end up
  /// causing a tap.
  ///
  /// This is emitted after [secondaryTapDown], and instead of
  /// [secondaryTapUp], if the tap gesture did not win.
  ///
  /// A gesture of this type has no details.
  secondaryTapCancel,

  /// A pointer that might cause a tap with a secondary button has contacted the
  /// screen at a particular location.
  ///
  /// This is emitted after a short timeout, even if the winning gesture has not
  /// yet been selected. If the tap gesture wins, [secondaryTapUp] will be
  /// emitted, otherwise [secondaryTapCancel] will be emitted.
  ///
  /// A gesture of this type has details of [TapDownDetails].
  secondaryTapDown,

  /// A pointer that will trigger a tap with a secondary button has stopped
  /// contacting the screen at a particular location.
  ///
  /// This triggers in the case of the tap gesture winning. If the tap gesture
  /// did not win, [secondaryTapCancel] is emitted instead.
  ///
  /// A gesture of this type has no details.
  secondaryTapUp,

  /// Called when a long press gesture with a tertiary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is emitted immediately after)
  /// [tertiaryLongPressStart]. The only difference between the two is that
  /// this gesture does not contain details of the position at which the
  /// pointer initially contacted the screen.
  ///
  /// A gesture of this type has no details.
  tertiaryLongPress,

  /// A pointer that previously triggered [tertiaryLongPressDown] will not
  /// end up causing a long-press.
  ///
  /// This triggers once the gesture loses if [tertiaryLongPressDown] has
  /// previously been triggered.
  ///
  /// If the user completed the long-press, and the gesture won, then
  /// [tertiaryLongPressStart] and [tertiaryLongPress] are emitted instead.
  ///
  /// A gesture of this type has no details.
  tertiaryLongPressCancel,

  /// The pointer has contacted the screen with a tertiary button, which might
  /// be the start of a long-press.
  ///
  /// This triggers after the pointer down gesture.
  ///
  /// If the user completes the long-press, and this gesture wins,
  /// [tertiaryLongPressStart] will be emitted after this gesture. Otherwise,
  /// [tertiaryLongPressCancel] will be emitted after this gesture.
  ///
  /// A gesture of this type has details of [LongPressDownDetails].
  tertiaryLongPressDown,

  /// A pointer that has triggered a long-press with a secondary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is emitted immediately before)
  /// [secondaryLongPressUp]. The only difference between the two is that
  /// this gesture contains details of the state of the pointer when it
  /// stopped contacting the screen, whereas [secondaryLongPressUp] does not.
  ///
  /// A gesture of this type has details of [LongPressDownDetails].
  tertiaryLongPressEnd,

  /// A pointer has been drag-moved after a long press with a secondary button.
  ///
  /// A gesture of this type has details of [LongPressMoveUpdateDetails].
  tertiaryLongPressMoveUpdate,

  /// Called when a long press gesture with a secondary button has been
  /// recognized.
  ///
  /// Triggered when a pointer has remained in contact with the screen at the
  /// same location for a long period of time.
  ///
  /// This is equivalent to (and is emitted immediately before)
  /// [secondaryLongPress]. The only difference between the two is that this
  /// gesture contains details of the position at which the pointer initially
  /// contacted the screen, whereas [secondaryLongPress] does not.
  ///
  /// A gesture of this type has details of [LongPressStartDetails].
  tertiaryLongPressStart,

  /// A pointer that has triggered a long-press with a secondary button has
  /// stopped contacting the screen.
  ///
  /// This is equivalent to (and is emitted immediately after)
  /// [secondaryLongPressEnd]. The only difference between the two is that
  /// this gesture does not contain details of the state of the pointer when
  /// it stopped contacting the screen.
  ///
  /// A gesture of this type has no details.
  tertiaryLongPressUp,

  /// The pointer that previously triggered [secondaryTapDown] will not end up
  /// causing a tap.
  ///
  /// This is emitted after [secondaryTapDown], and instead of
  /// [secondaryTapUp], if the tap gesture did not win.
  ///
  /// A gesture of this type has no details.
  tertiaryTapCancel,

  /// A pointer that might cause a tap with a tertiary button has contacted the
  /// screen at a particular location.
  ///
  /// This is emitted after a short timeout, even if the winning gesture has not
  /// yet been selected. If the tap gesture wins, [tertiaryTapUp] will be
  /// emitted, otherwise [tertiaryTapCancel] will be emitted.
  ///
  /// A gesture of this type has details of [TapDownDetails].
  tertiaryTapDown,

  /// A pointer that will trigger a tap with a tertiary button has stopped
  /// contacting the screen at a particular location.
  ///
  /// This triggers in the case of the tap gesture winning. If the tap gesture
  /// did not win, [tertiaryTapCancel] is emitted instead.
  ///
  /// A gesture of this type has no details.
  tertiaryTapUp,

  /// Emitted when a pointer that has not triggered an [tapDown] changes position.
  ///
  /// This is only fired for pointers which report their location when not down
  /// (e.g. mouse pointers, but not most touch pointers).
  ///
  /// A gesture of this type has no details.
  hover,

  /// The pointer issued a scroll gesture.
  ///
  /// Scrolling the scroll wheel on a mouse is an example that would emit a scroll
  /// gesture.
  ///
  /// A gesture of this type has details of [Offset], which is [PointerScrollEvent.scrollDelta].
  scroll,
}

/// Information about a gesture.
///
/// A gesture is triggered by pointer events, including touch, stylus, or mouse.
/// Gesture types are refering to [GestureDetector] (See details in [GestureType]).
///
/// This is carried as payload by [GestureSignal].
///
/// See also:
///
/// - [GestureSignal], which signal carries gesture as payload.
class Gesture {
  /// Creates a gesture.
  Gesture(
    this.type,
    this.kind,
    this.localPosition,
    this.chartSize,
    this.details, {
    this.localMoveStart,
    this.preScaleDetail,
  });

  /// The gesture type.
  final GestureType type;

  /// the kind of device that triggers the pointer event.
  final PointerDeviceKind kind;

  /// The local position of the pointer event that triggers this gesture.
  final Offset localPosition;

  /// The current size of the chart.
  ///
  /// It is usefull when calculating movement length ratios.
  final Size chartSize;

  /// Details about this gesture.
  ///
  /// They may be different class types or null according to [type] (See corresponding
  /// relations in [GestureType]).
  final dynamic details;

  /// The local position of pointer when a scale or long press starts.
  ///
  /// It is usefull when calculating movement spans in [GestureType.scaleUpdate],
  /// [GestureType.longPressMoveUpdate], [GestureType.secondaryLongPressMoveUpdate],
  /// and [GestureType.tertiaryLongPressMoveUpdate].
  final Offset? localMoveStart;

  // By hacking the scale start, Scale update always has it.

  /// Details of previous scale update.
  ///
  /// It is usefull to calculate delta position between scale updates, because
  /// [ScaleUpdateDetails.delta] is form the start instead of the previous one.
  ///
  /// Scale update gesture will always has this property, even the first update
  /// (It regards the scale start as the previous update.).
  final ScaleUpdateDetails? preScaleDetail;
}

/// The signal emitted when a gesture occurs.
class GestureSignal extends Signal {
  /// Creates a gesture signal.
  GestureSignal(this.gesture);

  @override
  SignalType get type => SignalType.gesture;

  /// Informations about the gesture.
  final Gesture gesture;
}

/// The gesture value operator.
class GestureOp extends Value<Gesture?> {
  @override
  bool get consume => true;
}
