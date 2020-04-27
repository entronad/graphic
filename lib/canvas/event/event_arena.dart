import 'dart:ui' show Offset;

import 'package:flutter/gestures.dart' show PointerEvent, ScaleUpdateDetails;

import 'graph_event.dart' show EventType, OriginalEvent;

const tapDelay = Duration(milliseconds: 500);
const touchDelay = Duration(milliseconds: 500);

const panBias = 40;
const tapBias = 40;

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

enum ListenerEventCategory {
  tap,
  longPress,
  pan,
  scale,
}

class EventArena {
  final Map<EventType, List<void Function(OriginalEvent)>> _callbacksMap = {};

  ListenerEventCategory _currentCagegory;

  PointerEvent _lastDown;

  PointerEvent _lastUp;

  // Max 2, if add more replace the second.
  final List<PointerEvent> _onScreenPointers = [];

  Offset _initialScaleOffset;

  Offset _initialMovePoint;

  void addEventListener(EventType eventType, void Function(OriginalEvent) callback) {
    if (_callbacksMap[eventType] == null) {
      _callbacksMap[eventType] = [];
    }
    _callbacksMap[eventType].add(callback);
  }

  void removeAllEventListener() => _callbacksMap.clear();

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
      _applyCallbacks(EventType.scaleStart, pointerEvent);
      _applyCallbacks(EventType.tapCancel, pointerEvent);
      _applyCallbacks(EventType.panCancel, pointerEvent);
      _currentCagegory = ListenerEventCategory.scale;
      _initialScaleOffset = _onScreenPointers[1].localPosition - _onScreenPointers[0].localPosition;
    } else {
      _applyCallbacks(EventType.tapDown, pointerEvent);
      _applyCallbacks(EventType.panDown, pointerEvent);
      _waitForTouch(pointerEvent);
    }

    _lastDown = pointerEvent;
  }

  void _onPointerMove(PointerEvent pointerEvent) {
    switch (_currentCagegory) {
      case ListenerEventCategory.longPress:
        final offset = pointerEvent.localPosition - _initialMovePoint;
        _applyCallbacks(EventType.longPressMoveUpdate, pointerEvent, offset: offset);
        break;
      case ListenerEventCategory.pan:
        final offset = pointerEvent.localPosition - _initialMovePoint;
        _applyCallbacks(EventType.panUpdate, pointerEvent, offset: offset);
        break;
      case ListenerEventCategory.scale:
        final scale = _calculateScale(pointerEvent);
        _applyCallbacks(EventType.scaleUpdate, pointerEvent, scale: scale);
        break;
      default:
        // null
        final bias = (pointerEvent.localPosition - _lastDown.localPosition).distance.abs();
        if (bias > panBias) {
          _applyCallbacks(EventType.panStart, pointerEvent);
          _applyCallbacks(EventType.tapCancel, pointerEvent);
          _currentCagegory = ListenerEventCategory.pan;
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
      case ListenerEventCategory.tap:
        // must be doubleTap
        final bias = (pointerEvent.localPosition - _lastUp.localPosition).distance.abs();
        if (bias < tapBias) {
          _applyCallbacks(EventType.tapCancel, pointerEvent);
          _applyCallbacks(EventType.doubleTap, pointerEvent);
          _currentCagegory = null;
        } else {
          // Without record.
          return;
        }
        break;
      case ListenerEventCategory.longPress:
        final offset = pointerEvent.localPosition - _initialMovePoint;
        _applyCallbacks(EventType.longPressUp, pointerEvent, offset: offset);
        _applyCallbacks(EventType.longPressEnd, pointerEvent, offset: offset);
        _currentCagegory = null;
        break;
      case ListenerEventCategory.pan:
        final offset = pointerEvent.localPosition - _initialMovePoint;
        _applyCallbacks(EventType.panEnd, pointerEvent, offset: offset);
        _currentCagegory = null;
        break;
      case ListenerEventCategory.scale:
        final scale = _calculateScale(pointerEvent);
        _applyCallbacks(EventType.scaleEnd, pointerEvent, scale: scale);
        _currentCagegory = null;
        break;
      default:
        // null
        // must be sigleTap
        _applyCallbacks(EventType.panCancel, pointerEvent);
        _waitForTap(pointerEvent);
        _currentCagegory = ListenerEventCategory.tap;
    }

    _lastUp = pointerEvent;
  }

  void _onPointerCancel(PointerEvent pointerEvent) {

  }

  void _onPointerSignal(PointerEvent pointerEvent) {
    
  }

  void _onTriggerTap(PointerEvent pointerEvent) {
    if (
      _currentCagegory == null
      && pointerEvent.pointer == _lastUp.pointer
    ) {
      _applyCallbacks(EventType.tapUp, pointerEvent);
      _applyCallbacks(EventType.tap, pointerEvent);
      _currentCagegory = null;
    }
  }

  void _onTriggerTouch(PointerEvent pointerEvent) {
    if (
      _currentCagegory == null
      && _onScreenPointers.length == 1
      && pointerEvent.pointer == _onScreenPointers[0].pointer
    ) {
      _applyCallbacks(EventType.longPressStart, pointerEvent);
      _applyCallbacks(EventType.longPress, pointerEvent);
      _applyCallbacks(EventType.tapCancel, pointerEvent);
      _applyCallbacks(EventType.panCancel, pointerEvent);
      _currentCagegory = ListenerEventCategory.longPress;
      _initialMovePoint = pointerEvent.localPosition;
    }
  }

  ScaleUpdateDetails _calculateScale(PointerEvent moveEvent) {
    PointerEvent focalEvent;
    // Ensureed that moveEvent is among _touchingEvents.
    if (_onScreenPointers[0].pointer == moveEvent.pointer) {
      focalEvent = _onScreenPointers[0];
    } else {
      focalEvent = _onScreenPointers[1];
    }

    final currentScaleOffset = _onScreenPointers[1].localPosition - _onScreenPointers[0].localPosition;
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
    EventType eventType,
    PointerEvent pointerEvent,
    {Offset offset,
    ScaleUpdateDetails scale,}
  ) {
    final originalEvent = OriginalEvent(eventType, pointerEvent, offset: offset, scale: scale);
    if (_callbacksMap[eventType] != null) {
      for (var callback in _callbacksMap[eventType]) {
        callback(originalEvent);
      }
    }
    if (_callbacksMap[EventType.all] != null) {
      for (var callback in _callbacksMap[EventType.all]) {
        callback(originalEvent);
      }
    }
  }
}
