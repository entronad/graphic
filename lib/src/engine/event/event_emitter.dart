import 'event_arena.dart' show EventType, Event;

mixin EventEmitter {
  final _events = <EventType, List<void Function(Event)>>{};

  void on(EventType type, void Function(Event) listener) {
    assert(type != null && listener != null);

    final events = _events[type] ?? <void Function(Event)>[];
    events.add(listener);
    _events[type] = events;
  }

  void emit(Event e) {
    assert(e != null);

    final type = e.type;
    final events = _events[type];
    if (events == null || events.isEmpty) {
      return;
    }
    for (var listener in events) {
      listener(e);
    }
  }

  void off(EventType type, [void Function(Event) listener]) {
    final events = _events[type];
    if (events == null || events.isEmpty) {
      return;
    }
    if (listener == null) {
      _events.remove(type);
      return;
    }
    for (var i = 0; i < events.length; i++) {
      if (events[i] == listener) {
        events.removeAt(i);
      }
    }
  }
}
