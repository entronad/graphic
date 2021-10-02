import 'dart:ui';

import 'package:flutter/gestures.dart';

// GestureType/GestureEvent: output of the arena

enum GestureType {
  tapDown,
  tapUp,
  tap,
  doubleTap,
  tapCancel,

  longPress,
  longPressStart,
  longPressMoveUpdate,
  longPressUp,
  longPressEnd,

  panDown,
  panStart,
  panUpdate,
  panEnd,
  panCancel,

  scaleStart,
  scaleUpdate,
  scaleEnd,

  // Mouse event types

  hover,
  scroll,
}

class Gesture {
  Gesture(
    this.type,
    this.pointerEvent,
    this.arenaSize,
    {this.offset,
    this.scale,
    this.scrollDelta,}
  );

  final GestureType type;

  final PointerEvent pointerEvent;

  final Size arenaSize;

  // Offset from original point, used for movement.
  final Offset? offset;

  final ScaleUpdateDetails? scale;

  final Offset? scrollDelta;
}

typedef GestureListener = void Function(Gesture);

const _tapDelay = Duration(milliseconds: 250);
const _touchDelay = Duration(milliseconds: 250);

const _panBias = 10;
const _tapBias = 10;

// ListenerEventType/ListenerEvent: input of arena, from Widget.Listener

// PointerEvent: triggers the ListenerEvent, from Widget.Listener

enum ListenerEventType {
  pointerDown,
  pointerMove,
  pointerUp,
  pointerCancel,
  pointerHover,
  pointerSignal,

  triggerTap,
  triggerTouch,
}

class ListenerEvent {
  ListenerEvent(this.type, this.pointerEvent);

  final ListenerEventType type;

  final PointerEvent pointerEvent;
}

enum _ListenerEventCategory {
  tap,
  longPress,
  pan,
  scale,
}

class GestureArena {
  GestureArena(this.size);

  Size size;

  final List<GestureListener?> _listeners = [];

  _ListenerEventCategory? _currentCagegory;

  late PointerEvent _lastDown;

  late PointerEvent _lastUp;

  // Max 2, if add more replace the second.
  final List<PointerEvent> _onScreenPointers = [];

  Offset? _initialScaleOffset;

  Offset? _initialMovePoint;

  int on(GestureListener listener) {
    _listeners.add(listener);
    return _listeners.length - 1;
  }

  void off(int id) =>
    _listeners[id] = null;

  void clear() =>
    _listeners.clear();

  void emit(ListenerEvent listenerEvent) {
    switch (listenerEvent.type) {
      case ListenerEventType.pointerDown:
        _onPointerDown(listenerEvent.pointerEvent);
        break;
      case ListenerEventType.pointerMove:
        _onPointerMove(listenerEvent.pointerEvent);
        break;
      case ListenerEventType.pointerUp:
        _onPointerUp(listenerEvent.pointerEvent);
        break;
      case ListenerEventType.pointerCancel:
        _onPointerCancel(listenerEvent.pointerEvent);
        break;
      case ListenerEventType.pointerHover:
        _onPointerHover(listenerEvent.pointerEvent);
        break;
      case ListenerEventType.pointerSignal:
        _onPointerSignal(listenerEvent.pointerEvent);
        break;
      case ListenerEventType.triggerTap:
        _onTriggerTap(listenerEvent.pointerEvent);
        break;
      case ListenerEventType.triggerTouch:
        _onTriggerTouch(listenerEvent.pointerEvent);
        break;
      default:
    }
  }

  void _onPointerDown(PointerEvent pointerEvent) async {
    if (_onScreenPointers.length > 1 || _currentCagegory != null) {
      // Without record.
      return;
    }
    _onScreenPointers.add(pointerEvent);

    if (_onScreenPointers.length == 2) {
      await _applyCallbacks(GestureType.scaleStart, pointerEvent);
      await _applyCallbacks(GestureType.tapCancel, pointerEvent);
      await _applyCallbacks(GestureType.panCancel, pointerEvent);
      _currentCagegory = _ListenerEventCategory.scale;
      _initialScaleOffset = _onScreenPointers[1].localPosition - _onScreenPointers[0].localPosition;
    } else {
      await _applyCallbacks(GestureType.tapDown, pointerEvent);
      await _applyCallbacks(GestureType.panDown, pointerEvent);
      _waitForTouch(pointerEvent);
    }

    _lastDown = pointerEvent;
  }

  void _onPointerMove(PointerEvent pointerEvent) async {
    switch (_currentCagegory) {
      case _ListenerEventCategory.longPress:
        final offset = pointerEvent.localPosition - _initialMovePoint!;
        await _applyCallbacks(GestureType.longPressMoveUpdate, pointerEvent, offset: offset);
        break;
      case _ListenerEventCategory.pan:
        final offset = pointerEvent.localPosition - _initialMovePoint!;
        await _applyCallbacks(GestureType.panUpdate, pointerEvent, offset: offset);
        break;
      case _ListenerEventCategory.scale:
        final scale = _calculateScale(pointerEvent);
        await _applyCallbacks(GestureType.scaleUpdate, pointerEvent, scale: scale);
        break;
      case _ListenerEventCategory.tap:
        break;
      default:
        // null
        final bias = (pointerEvent.localPosition - _lastDown.localPosition).distance.abs();
        if (bias > _panBias) {
          await _applyCallbacks(GestureType.panStart, pointerEvent);
          await _applyCallbacks(GestureType.tapCancel, pointerEvent);
          _currentCagegory = _ListenerEventCategory.pan;
          _initialMovePoint = pointerEvent.localPosition;
        }
    }
  }

  void _onPointerUp(PointerEvent pointerEvent) async {
    for (var i = 0; i < _onScreenPointers.length; i++) {
      if (pointerEvent.pointer == _onScreenPointers[i].pointer) {
        _onScreenPointers.removeAt(i);
      }
    }

    switch (_currentCagegory) {
      case _ListenerEventCategory.tap:
        // must be doubleTap
        final bias = (pointerEvent.localPosition - _lastUp.localPosition).distance.abs();
        if (bias < _tapBias) {
          await _applyCallbacks(GestureType.doubleTap, pointerEvent);
          await _applyCallbacks(GestureType.tapCancel, pointerEvent);
          _currentCagegory = null;
        } else {
          // Without record.
          return;
        }
        break;
      case _ListenerEventCategory.longPress:
        final offset = pointerEvent.localPosition - _initialMovePoint!;
        await _applyCallbacks(GestureType.longPressUp, pointerEvent, offset: offset);
        await _applyCallbacks(GestureType.longPressEnd, pointerEvent, offset: offset);
        _currentCagegory = null;
        break;
      case _ListenerEventCategory.pan:
        final offset = pointerEvent.localPosition - _initialMovePoint!;
        await _applyCallbacks(GestureType.panEnd, pointerEvent, offset: offset);
        _currentCagegory = null;
        break;
      case _ListenerEventCategory.scale:
        final scale = _calculateScale(pointerEvent);
        await _applyCallbacks(GestureType.scaleEnd, pointerEvent, scale: scale);
        _currentCagegory = null;
        break;
      default:
        // null
        // must be sigleTap
        await _applyCallbacks(GestureType.panCancel, pointerEvent);
        _waitForTap(pointerEvent);
        _currentCagegory = _ListenerEventCategory.tap;
    }

    _lastUp = pointerEvent;
  }

  void _onPointerCancel(PointerEvent pointerEvent) async {

  }

  void _onPointerHover(PointerEvent pointerEvent) async {
    await _applyCallbacks(GestureType.hover, pointerEvent);
  }

  void _onPointerSignal(PointerEvent pointerEvent) async {
    if (pointerEvent is PointerScrollEvent) {
      await _applyCallbacks(GestureType.scroll, pointerEvent, scrollDelta: pointerEvent.scrollDelta);
    }
  }

  void _onTriggerTap(PointerEvent pointerEvent) async {
    if (
      _currentCagegory == _ListenerEventCategory.tap
      && pointerEvent.pointer == _lastUp.pointer
    ) {
      await _applyCallbacks(GestureType.tapUp, pointerEvent);
      await _applyCallbacks(GestureType.tap, pointerEvent);
      _currentCagegory = null;
    }
  }

  void _onTriggerTouch(PointerEvent pointerEvent) async {
    if (
      _currentCagegory == null
      && _onScreenPointers.length == 1
      && pointerEvent.pointer == _onScreenPointers[0].pointer
    ) {
      await _applyCallbacks(GestureType.longPress, pointerEvent);
      await _applyCallbacks(GestureType.longPressStart, pointerEvent);
      await _applyCallbacks(GestureType.tapCancel, pointerEvent);
      await _applyCallbacks(GestureType.panCancel, pointerEvent);
      _currentCagegory = _ListenerEventCategory.longPress;
      _initialMovePoint = pointerEvent.localPosition;
    }
  }

  /// Gesture.scale is created by arena.
  /// The scale and rotation is calculated from the initial.
  ScaleUpdateDetails _calculateScale(PointerEvent moveEvent) {
    PointerEvent focalEvent;
    // Ensureed that moveEvent is among _touchingEvents.
    if (
      _onScreenPointers.length == 1  // scaleEnd
        || _onScreenPointers[0].pointer != moveEvent.pointer
    ) {
      focalEvent = _onScreenPointers[0];
    } else {
      focalEvent = _onScreenPointers[1];
    }

    final currentScaleOffset = moveEvent.localPosition - focalEvent.localPosition;
    final horizontalScale = (currentScaleOffset.dx / _initialScaleOffset!.dx).abs();
    final verticalScale = (currentScaleOffset.dy / _initialScaleOffset!.dy).abs();
    final scale = (currentScaleOffset.distance / _initialScaleOffset!.distance).abs();
    final rotation = (currentScaleOffset.direction - _initialScaleOffset!.direction).abs();

    return ScaleUpdateDetails(
      focalPoint: focalEvent.position,
      localFocalPoint: focalEvent.localPosition,
      scale: scale,
      horizontalScale: horizontalScale,
      verticalScale: verticalScale,
      rotation: rotation,
    );
  }

  void _waitForTap(PointerEvent pointerEvent) async {
    await Future.delayed(_tapDelay);
    emit(ListenerEvent(ListenerEventType.triggerTap, pointerEvent));
  }

  void _waitForTouch(PointerEvent pointerEvent) async {
    await Future.delayed(_touchDelay);
    emit(ListenerEvent(ListenerEventType.triggerTouch, pointerEvent));
  }

  Future<void> _applyCallbacks(
    GestureType gestureType,
    PointerEvent pointerEvent,
    {Offset? offset,
    ScaleUpdateDetails? scale,
    Offset? scrollDelta,}
  ) async {
    final gesture = Gesture(
      gestureType,
      pointerEvent,
      size,
      offset: offset,
      scale: scale,
      scrollDelta: scrollDelta,
    );
    for (var listener in _listeners) {
      if (listener != null) {
        listener(gesture);
      }
    }
  }
}
