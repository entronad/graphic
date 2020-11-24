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
}

class GestureEvent {
  GestureEvent(this.type, this.pointerEvent, {this.offset, this.scale});

  final GestureType type;

  final PointerEvent pointerEvent;

  // Offset from original point, used for movement.
  final Offset offset;

  final ScaleUpdateDetails scale;
}

const tapDelay = Duration(milliseconds: 250);
const touchDelay = Duration(milliseconds: 250);

const panBias = 10;
const tapBias = 10;

// ListenerEventType/ListenerEvent: input of arena, from Widget.Listener

// PointerEvent: triggers the ListenerEvent, from Widget.Listener

enum ListenerEventType {
  pointerDown,
  pointerMove,
  pointerUp,
  pointerCancel,
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
  final Map<GestureType, List<void Function(GestureEvent)>> _gestureEvents = {};

  _ListenerEventCategory _currentCagegory;

  PointerEvent _lastDown;

  PointerEvent _lastUp;

  // Max 2, if add more replace the second.
  final List<PointerEvent> _onScreenPointers = [];

  Offset _initialScaleOffset;

  Offset _initialMovePoint;

  void on(GestureType type, void Function(GestureEvent) callback) {
    if (_gestureEvents[type] == null) {
      _gestureEvents[type] = [];
    }
    _gestureEvents[type].add(callback);
  }

  void removeAllEventListener() => _gestureEvents.clear();

  void off([GestureType type, void Function(GestureEvent) listener]) {
    if (type == null) {
      _gestureEvents.clear();
      return;
    }

    if (listener == null) {
      _gestureEvents.remove(type);
      return;
    }

    // Type must not be null if listener is specified.
    final events = _gestureEvents[type];
    if (events == null || events.isEmpty) {
      return;
    }
    for (var i = 0; i < events.length; i++) {
      if (events[i] == listener) {
        events.removeAt(i);
      }
    }
  }

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

  void _onPointerDown(PointerEvent pointerEvent) {
    if (_onScreenPointers.length > 1 || _currentCagegory != null) {
      // Without record.
      return;
    }
    _onScreenPointers.add(pointerEvent);

    if (_onScreenPointers.length == 2) {
      _applyCallbacks(GestureType.scaleStart, pointerEvent);
      _applyCallbacks(GestureType.tapCancel, pointerEvent);
      _applyCallbacks(GestureType.panCancel, pointerEvent);
      _currentCagegory = _ListenerEventCategory.scale;
      _initialScaleOffset = _onScreenPointers[1].localPosition - _onScreenPointers[0].localPosition;
    } else {
      _applyCallbacks(GestureType.tapDown, pointerEvent);
      _applyCallbacks(GestureType.panDown, pointerEvent);
      _waitForTouch(pointerEvent);
    }

    _lastDown = pointerEvent;
  }

  void _onPointerMove(PointerEvent pointerEvent) {
    switch (_currentCagegory) {
      case _ListenerEventCategory.longPress:
        final offset = pointerEvent.localPosition - _initialMovePoint;
        _applyCallbacks(GestureType.longPressMoveUpdate, pointerEvent, offset: offset);
        break;
      case _ListenerEventCategory.pan:
        final offset = pointerEvent.localPosition - _initialMovePoint;
        _applyCallbacks(GestureType.panUpdate, pointerEvent, offset: offset);
        break;
      case _ListenerEventCategory.scale:
        final scale = _calculateScale(pointerEvent);
        _applyCallbacks(GestureType.scaleUpdate, pointerEvent, scale: scale);
        break;
      case _ListenerEventCategory.tap:
        break;
      default:
        // null
        final bias = (pointerEvent.localPosition - _lastDown.localPosition).distance.abs();
        if (bias > panBias) {
          _applyCallbacks(GestureType.panStart, pointerEvent);
          _applyCallbacks(GestureType.tapCancel, pointerEvent);
          _currentCagegory = _ListenerEventCategory.pan;
          _initialMovePoint = pointerEvent.localPosition;
        }
    }
  }

  void _onPointerUp(PointerEvent pointerEvent) {
    for (var i = 0; i < _onScreenPointers.length; i++) {
      if (pointerEvent.pointer == _onScreenPointers[i].pointer) {
        _onScreenPointers.removeAt(i);
      }
    }

    switch (_currentCagegory) {
      case _ListenerEventCategory.tap:
        // must be doubleTap
        final bias = (pointerEvent.localPosition - _lastUp.localPosition).distance.abs();
        if (bias < tapBias) {
          _applyCallbacks(GestureType.doubleTap, pointerEvent);
          _applyCallbacks(GestureType.tapCancel, pointerEvent);
          _currentCagegory = null;
        } else {
          // Without record.
          return;
        }
        break;
      case _ListenerEventCategory.longPress:
        final offset = pointerEvent.localPosition - _initialMovePoint;
        _applyCallbacks(GestureType.longPressUp, pointerEvent, offset: offset);
        _applyCallbacks(GestureType.longPressEnd, pointerEvent, offset: offset);
        _currentCagegory = null;
        break;
      case _ListenerEventCategory.pan:
        final offset = pointerEvent.localPosition - _initialMovePoint;
        _applyCallbacks(GestureType.panEnd, pointerEvent, offset: offset);
        _currentCagegory = null;
        break;
      case _ListenerEventCategory.scale:
        final scale = _calculateScale(pointerEvent);
        _applyCallbacks(GestureType.scaleEnd, pointerEvent, scale: scale);
        _currentCagegory = null;
        break;
      default:
        // null
        // must be sigleTap
        _applyCallbacks(GestureType.panCancel, pointerEvent);
        _waitForTap(pointerEvent);
        _currentCagegory = _ListenerEventCategory.tap;
    }

    _lastUp = pointerEvent;
  }

  void _onPointerCancel(PointerEvent pointerEvent) {

  }

  void _onPointerSignal(PointerEvent pointerEvent) {
    
  }

  void _onTriggerTap(PointerEvent pointerEvent) {
    if (
      _currentCagegory == _ListenerEventCategory.tap
      && pointerEvent.pointer == _lastUp.pointer
    ) {
      _applyCallbacks(GestureType.tapUp, pointerEvent);
      _applyCallbacks(GestureType.tap, pointerEvent);
      _currentCagegory = null;
    }
  }

  void _onTriggerTouch(PointerEvent pointerEvent) {
    if (
      _currentCagegory == null
      && _onScreenPointers.length == 1
      && pointerEvent.pointer == _onScreenPointers[0].pointer
    ) {
      _applyCallbacks(GestureType.longPress, pointerEvent);
      _applyCallbacks(GestureType.longPressStart, pointerEvent);
      _applyCallbacks(GestureType.tapCancel, pointerEvent);
      _applyCallbacks(GestureType.panCancel, pointerEvent);
      _currentCagegory = _ListenerEventCategory.longPress;
      _initialMovePoint = pointerEvent.localPosition;
    }
  }

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
    final horizontalScale = (currentScaleOffset.dx / _initialScaleOffset.dx).abs();
    final verticalScale = (currentScaleOffset.dy / _initialScaleOffset.dy).abs();
    final scale = (currentScaleOffset.distance / _initialScaleOffset.distance).abs();
    final rotation = (currentScaleOffset.direction - _initialScaleOffset.direction).abs();

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
    await Future.delayed(tapDelay);
    emit(ListenerEvent(ListenerEventType.triggerTap, pointerEvent));
  }

  void _waitForTouch(PointerEvent pointerEvent) async {
    await Future.delayed(touchDelay);
    emit(ListenerEvent(ListenerEventType.triggerTouch, pointerEvent));
  }

  void _applyCallbacks(
    GestureType gestureType,
    PointerEvent pointerEvent,
    {Offset offset,
    ScaleUpdateDetails scale,}
  ) {
    final event = GestureEvent(gestureType, pointerEvent, offset: offset, scale: scale);
    if (_gestureEvents[gestureType] != null) {
      for (var callback in _gestureEvents[gestureType]) {
        callback(event);
      }
    }
  }
}
