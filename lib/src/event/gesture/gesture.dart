import 'dart:ui';

import 'package:flutter/gestures.dart';

import 'arena.dart' as arena;
import '../event.dart';

class GestureEvent extends Event {
  GestureEvent(
    this.type,
    this.pointerEvent,
    {this.offset,
    this.scale,
    this.scrollDelta,}
  );

  final arena.GestureType type;

  final PointerEvent pointerEvent;

  // Offset from original point, used for movement.
  final Offset? offset;

  final ScaleUpdateDetails? scale;

  final Offset? scrollDelta;
}

GestureEvent _toGestureEvent(arena.GestureEvent event) =>
  GestureEvent(
    event.type,
    event.pointerEvent,
    offset: event.offset,
    scale: event.scale,
    scrollDelta: event.scrollDelta,
  );

arena.GestureType _toArenaType(EventType type) =>
  type == EventType.tapDown ? arena.GestureType.tapDown :
  type == EventType.tapUp ? arena.GestureType.tapUp :
  type == EventType.tap ? arena.GestureType.tap :
  type == EventType.doubleTap ? arena.GestureType.doubleTap :
  type == EventType.tapCancel ? arena.GestureType.tapCancel :
  type == EventType.longPress ? arena.GestureType.longPress :
  type == EventType.longPressStart ? arena.GestureType.longPressStart :
  type == EventType.longPressMoveUpdate ? arena.GestureType.longPressMoveUpdate :
  type == EventType.longPressUp ? arena.GestureType.longPressUp :
  type == EventType.longPressEnd ? arena.GestureType.longPressEnd :
  type == EventType.panDown ? arena.GestureType.panDown :
  type == EventType.panStart ? arena.GestureType.panStart :
  type == EventType.panUpdate ? arena.GestureType.panUpdate :
  type == EventType.panEnd ? arena.GestureType.panEnd :
  type == EventType.panCancel ? arena.GestureType.panCancel :
  type == EventType.scaleStart ? arena.GestureType.scaleStart :
  type == EventType.scaleUpdate ? arena.GestureType.scaleUpdate :
  type == EventType.scaleEnd ? arena.GestureType.scaleEnd :
  throw UnimplementedError('$type has no equivalent GestureType.');

class GestureSource extends EventSource<GestureEvent> {
  GestureSource(this._arena);

  final arena.GestureArena _arena;

  final Map<EventListener<GestureEvent>, arena.GestureEventListener> _avatars = {};

  @override
  void on(EventType type, EventListener<GestureEvent> listener) {
    if (_avatars[listener] == null) {
      _avatars[listener] = (arena.GestureEvent arenaEvent) {
        listener(_toGestureEvent(arenaEvent));
      };
    }

    _arena.on(
      _toArenaType(type),
      _avatars[listener]!,
    );
  }

  @override
  void off([EventType? type, EventListener<GestureEvent>? listener]) {
    _arena.off(
      type != null ? _toArenaType(type) : null,
      _avatars[listener],
    );
  }

  @override
  void emit(GestureEvent event) =>
    throw UnimplementedError('Event is emit by arena');
}
