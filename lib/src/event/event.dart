enum EventType {
  // Gesture events.
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
  hover,
  scroll,

  // Chart container resize.
  resize,

  // Data source change.
  changeData,
}

// TODO: equality
abstract class Event {
  
}

typedef EventListener<E extends Event> = void Function(E);

typedef EventPredivate<E extends Event> = bool Function(E);

abstract class EventSource<E extends Event> {
  void on(EventType type, EventListener<E> listener);

  void off([EventType? type, EventListener<E>? listener]);
}
