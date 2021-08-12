import 'package:graphic/src/event/event.dart';

class EventStream<E extends Event> {
  EventStream({
    EventPredivate<E>? filter,
    EventListener<E>? listener,
  })
    : _filter = filter,
      _listener = listener;

  E? _last;

  EventPredivate<E>? _filter;

  EventListener<E>? _listener;

  final Set<EventStream> targets = {};

  E? get last => _last;

  void emit(E event) {
    if (_filter == null || _filter!(event)) {
      _last = event;
      if (_listener != null) {
        _listener!(event);
      }
      for (var target in targets) {
        target.emit(event);
      }
    }
  }

  EventStream listen(EventListener<E> listener) {
    final target = EventStream(listener: listener);
    targets.add(target);
    return target;
  }
}
