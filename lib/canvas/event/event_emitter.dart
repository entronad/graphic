import 'graph_event.dart' show EventTag, GraphEvent;

class EventOperation {
  EventOperation(this.callback, this.once);

  final void Function(GraphEvent) callback;
  final bool once;
}

abstract class EventEmitter {
  Map<EventTag, List<EventOperation>> _events = {};

  /// Listen to an event.
  EventEmitter on(EventTag evt, void Function(GraphEvent) callback, [bool once]) {
    _events[evt] ??= [];
    _events[evt].add(EventOperation(
      callback,
      once,
    ));
    return this;
  }

  /// Listen to an event for once.
  EventEmitter once(EventTag evt, void Function(GraphEvent) callback)
    => this.on(evt, callback, true);
  
  /// Emit an event.
  void emit(EventTag evt, GraphEvent arg) {
    final events = _events[evt] ?? [];
    final wildcardEvents = _events[EventTag.all] ?? [];

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
  EventEmitter off([EventTag evt, void Function(GraphEvent) callback]) {
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
