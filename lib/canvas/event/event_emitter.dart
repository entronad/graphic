import 'package:flutter/gestures.dart';

// GestureRecognizer types, api refers to flutter 1.12.13
enum EventType {
  tap,
  tapDown,
  tapUp,
  tapCancel,

  secondaryTapDown,
  secondaryTapUp,
  secondaryTapCancel,

  doubleTap,

  longPress,
  longPressStart,
  longPressMoveUpdate,
  longPressUp,
  longPressEnd,

  horizontalDragStart,
  horizontalDragDown,
  horizontalDragUpdate,
  horizontalDragEnd,
  horizontalDragCancel,

  verticalDragStart,
  verticalDragDown,
  verticalDragUpdate,
  verticalDragEnd,
  verticalDragCancel,

  panStart,
  panDown,
  panUpdate,
  panEnd,
  panCancel,
  
  scaleStart,
  scaleUpdate,
  scaleEnd,

  forcePressStart,
  forcePressUpdate,
  forcePressPeak,
  forcePressEnd,

  wildcard,
}

class EventDetails implements
  TapDownDetails,
  TapUpDetails,
  LongPressStartDetails,
  LongPressMoveUpdateDetails,
  LongPressEndDetails,
  DragStartDetails,
  DragDownDetails,
  DragUpdateDetails,
  DragEndDetails,
  ScaleStartDetails,
  ScaleUpdateDetails,
  ScaleEndDetails,
  ForcePressDetails
{
  EventDetails({
    this.globalPosition = Offset.zero,
    Offset localPosition,

    this.offsetFromOrigin = Offset.zero,
    Offset localOffsetFromOrigin,

    this.velocity = Velocity.zero,

    this.delta = Offset.zero,

    this.focalPoint = Offset.zero,
    Offset localFocalPoint,

    this.scale = 1.0,
    this.horizontalScale = 1.0,
    this.verticalScale = 1.0,
    this.rotation = 0.0,
    
    this.kind,
    this.pressure,
    this.primaryDelta,
    this.primaryVelocity,
    this.sourceTimeStamp,
  })
    : localPosition = localPosition ?? globalPosition,
      localOffsetFromOrigin = localOffsetFromOrigin ?? offsetFromOrigin,
      localFocalPoint = localFocalPoint ?? focalPoint;

  final Offset delta;

  final Offset focalPoint;

  final Offset globalPosition;

  final double horizontalScale;

  final PointerDeviceKind kind;

  final Offset localFocalPoint;

  final Offset localOffsetFromOrigin;

  final Offset localPosition;

  final Offset offsetFromOrigin;

  final double pressure;

  final double primaryDelta;

  final double primaryVelocity;

  final double rotation;

  final double scale;

  final Duration sourceTimeStamp;

  final Velocity velocity;

  final double verticalScale;
}

typedef EventListener = void Function(EventDetails event);

class EventOperation {
  EventOperation(this.callback, this.once);

  final EventListener callback;
  final bool once;
}

abstract class EventEmitter {
  Map<EventType, List<EventOperation>> _events = {};

  /// Listen to an event.
  EventEmitter on(EventType evt, EventListener callback, [bool once]) {
    _events[evt] ??= [];
    _events[evt].add(EventOperation(
      callback,
      once,
    ));
    return this;
  }

  /// Listen to an event for once.
  EventEmitter once(EventType evt, EventListener callback)
    => this.on(evt, callback, true);
  
  /// Emit an event.
  void emit(EventType evt, EventDetails arg) {
    final events = _events[evt] ?? [];
    final wildcardEvents = _events[EventType.wildcard] ?? [];

    // The real handler for emittion.
    final doEmit = (List<EventOperation> es) {
      var length = es.length;
      for (var i = 0; i < length; i++) {
        final callback = es[i].callback;
        final once = es[i].once;

        if (once) {
          es.removeAt(i);

          if (es.isEmpty) {
            _events.remove(evt);
          }

          length --;
          i --;
        }

        callback(arg);
      }
    };

    doEmit(events);
    doEmit(wildcardEvents);
  }

  /// Cancel listening to an event, or a chennel.
  EventEmitter off([EventType evt, EventListener callback]) {
    if (evt == null) {
      // off() will cancel all.
      _events = {};
    } else {
      if (callback == null) {
        // off(evt) will cancel all callbacks of an event.
        _events.remove(evt);
      } else {
        // off(evt, callback) will cancel a certain callback.
        final events = _events[evt] ?? [];

        var length = events.length;
        for (var i = 0; i < length; i++) {
          if (events[i].callback == callback) {
            events.removeAt(i);
            length --;
            i --;
          }
        }

        if (events.isEmpty) {
          _events.remove(evt);
        }
      }
    }

    return this;
  }

  /// Get all current events.
  get events => _events;
}
