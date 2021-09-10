enum EventType {
  gesture,
  resize,
  changeData,
}

// TODO: equality
abstract class Event {
  EventType get type;
}

typedef EventListener<E extends Event> = void Function(E);

class EventSource<E extends Event> {
  final _listeners = <EventListener<E>?>[];

  int on(EventListener<E> listener) {
    _listeners.add(listener);
    return _listeners.length - 1;
  }

  void off(int id) =>
    _listeners[id] = null;

  void clear() =>
    _listeners.clear();

  void emit(E event) {
    for (var listener in _listeners) {
      if (listener != null) {
        listener(event);
      }
    }
  }
}
