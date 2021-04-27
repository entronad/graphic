import 'dataflow.dart';
import 'util/debounce.dart' as debounce_util;

var streamId = 0;

// TODO: mock event class
class Event {
  Dataflow? dataflow;
}

typedef EventFilter = bool Function(Event);

typedef EventApply = Event Function(Event);

typedef EventReceive = void Function(Event);

class EventStream {
  EventStream(
    [EventFilter? filter,
    EventApply? apply,
    EventReceive? receive,]
  ) : _id = ++streamId {
    if (receive != null) {
      this.receive = receive;
    } else {
      this.receive = _defaultReceive;
    }
    if (filter != null) {
      _filter = filter;
    }
    if (apply != null) {
      _apply = apply;
    }
  }

  int _id;

  var value;

  EventReceive receive =
    (_) { throw UnimplementedError('Receive not assigned.'); };
  
  EventFilter _filter = (_) => true;

  EventApply _apply = (evt) => evt;

  Set<EventStream>? _targets;

  bool consume = false;

  int get id => _id;

  Set<EventStream> get targets => _targets ?? {};

  void _defaultReceive(Event evt) {
    if (_filter(evt)) {
      value = _apply(evt);

      if (_targets != null) {
        for (var target in targets) {
          target.receive(value);
        }
      }

      if (consume) {
        // TODO: evt stop propagation
      }
    }
  }

  EventStream filter(EventFilter filter) {
    final s = EventStream(filter, null, null);
    targets.add(s);
    return s;
  }

  EventStream apply(EventApply apply) {
    final s = EventStream(null, apply, null);
    targets.add(s);
    return s;
  }

  EventStream merge(List<EventStream> evts) {
    final s = EventStream();

    targets.add(s);
    for (var evt in evts) {
      evt.targets.add(s);
    }

    return s;
  }

  EventStream throttle(Duration pause) {
    var t = DateTime.fromMicrosecondsSinceEpoch(0);
    return filter((_) {
      final now = DateTime.now();
      if (now.isAfter(t.add(pause))) {
        t = now;
        return true;
      } else {
        return false;
      }
    });
  }

  EventStream debounce(Duration delay) {
    final s = EventStream();

    targets.add(EventStream(null, null, debounce_util.debounce(delay, (e) {
      final df = e.dataflow;
      s.receive(e);
      if (df != null) {
        df.run();
      }
    })));

    return s;
  }

  EventStream between(EventStream a, EventStream b) {
    var active = false;
    a.targets.add(EventStream(null, null, (_) { active = true; }));
    b.targets.add(EventStream(null, null, (_) { active = false; }));
    return filter((_) => active);
  }

  // TODO: detach
}
