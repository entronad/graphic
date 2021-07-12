

import 'package:collection/collection.dart';
import 'package:graphic/src/dataflow/pulse/multi_pulse.dart';
import 'package:graphic/src/event/event.dart';
import 'package:graphic/src/util/assert.dart';

import 'operator/operator.dart';
import 'pulse/pulse.dart';
import 'change_set.dart';
import 'tuple.dart';
import 'event_stream.dart';

typedef Hook = Future<void> Function();

class Dataflow {
  int _clock = 0;

  int _currentRank = 0;

  Set<Operator> _touched = {};

  Pulse? _pulse;

  HeapPriorityQueue<Operator> _heap = HeapPriorityQueue(
    (a, b) => a.qRank - b.qRank,
  );

  // To record input pulses of some operators.
  // Set in pulse(), used in getPulse().
  final Map<int, Pulse> _inputs = {};

  // {hook: priority}
  final Map<Hook, int> _postruns = {};

  Future<Dataflow>? _running;

  Operator add(
    Operator op,
    [Map<String, dynamic>? params,
    bool reactive = true,]
  ) {
    _rank(op);
    if (params != null) {
      connect(op, op.setParams(params, reactive: reactive));
    }
    touch(op);
    return op;
  }

  Dataflow connect(Operator target, Set<Operator> sources) {
    for (var source in sources) {
      if (target.rank < source.rank) {
        _rerank(target);
        return this;
      }
    }
    return this;
  }

  void _rank(Operator op) {
    // Start form 0, like list index.
    op.rank = _currentRank++;
  }

  void _rerank(Operator op) {
    final queue = [op];

    while (queue.isNotEmpty) {
      var cur = queue.removeLast();
      _rank(cur);
      for (var target in cur.targets.toList().reversed) {
        queue.add(target);
        if (target == op) {
          throw ArgumentError('Cycle detected in dataflow graph.');
        }
      }
    }
  }

  Dataflow pulse (
    Operator op,
    ChangeSet changeSet,
    {skip = false,}
  ) {
    touch(op, skip: skip);

    final pulse = Pulse(this, _clock + (_pulse != null ? 0 : 1));
    final tuples = op.pulse?.source ?? <Tuple>[];

    // pulse.target = op;

    _inputs[op.id] = changeSet.pulse(pulse, tuples);

    return this;
  }

  Dataflow touch(
    Operator op,
    {skip = false,}
  ) {
    if (_pulse != null) {
      _enqueue(op);
    } else {
      _touched.add(op);
    }
    if (skip) {
      op.skip = true;
    }
    return this;
  }

  Dataflow update<V>(
    Operator<V> op,
    V value,
    {bool force = false,
    bool skip = false,}
  ) {
    if (op.set(value) || force) {
      touch(op, skip: skip);
    }
    return this;
  }

  Dataflow ingest(
    Operator target,
    List<Tuple> data,
  ) => pulse(target, ChangeSet().add(data));

  Future<Dataflow> evaluate(
    [Hook? prerun,
    Hook? postrun]
  ) async {
    assert(_pulse == null);

    if (prerun != null) {
      await prerun();
    }

    if (_touched.isEmpty) {
      return this;
    }

    final clock = ++_clock;

    _pulse = Pulse(this, clock);

    for (var op in _touched) {
      _enqueue(op, force: true);
    }
    _touched.clear();

    while (_heap.isNotEmpty) {
      final op = _heap.removeFirst();

      if (op.rank != op.qRank) {
        _enqueue(op, force: true);
        continue;
      }

      final next = op.run(_getPulse(op));

      if (next != null) {
        for (var targetOp in op.targets) {
          _enqueue(targetOp);
        }
      }
    }

    _inputs.clear();
    _pulse = null;

    if (_postruns.isNotEmpty) {
      final pr = _postruns.entries.sorted((a, b) => b.value - a.value);
      _postruns.clear();
      for (var entry in pr) {
        await entry.key();
      }
    }

    if (postrun != null) {
      await postrun();
    }

    return this;
  }

  Future<Dataflow> runAsync(
    [Hook? prerun,
    Hook? postrun]
  ) async {
    while (_running != null) {
      await _running;
    }

    _running = evaluate(prerun, postrun)
      .then(
        (_) {_running = null; return this;},
        onError:  (_) {_running = null;},
      );
    
    return _running!;
  }

  Dataflow run(
    [Hook? prerun,
    Hook? postrun]
  ) {
    assert(_pulse == null);

    evaluate(prerun, postrun);

    return this;
  }

  Dataflow runAfter(
    Hook postrun,
    {bool enqueue = false,
    int priority = 0,}
  ) {
    if (_pulse != null || enqueue) {
      _postruns[postrun] = priority;
    } else {
      postrun();
    }
    return this;
  }

  void _enqueue(
    Operator op,
    {force = false,}
  ) {
    final noPulse = op.clock < _clock;
    if (noPulse) {
      op.clock = _clock;
    }
    if (noPulse || force) {
      op.qRank = op.rank;
      _heap.add(op);
    }
  }

  Pulse _getPulse(Operator op) {
    final sources = op.sources;
    return (sources.length > 1)
      ? MultiPulse(this, _clock, sources.map((so) => so.pulse!).toList())
      : _inputs[op.id] ?? _getSinglePulse(_pulse!, sources.first.pulse);
  }

  Pulse _getSinglePulse(Pulse p, Pulse? sp) {
    if (sp?.clock == p.clock) {
      return sp!;
    }

    p = p.fork(PulseFlags.background);
    if (sp != null) {
      p.source = sp.source;
    }
    return p;
  }

  EventStream<E> createEventStream<E extends Event>(
    EventSource<E> source,
    EventType type,
    {EventPredivate<E>? filter,
    EventListener<E>? listener,}
  ) {
    final stream = EventStream<E>(
      filter: filter,
      listener: listener,
    );

    source.on(type, (E event) {
      stream.emit(event);
      run();
    });

    return stream;
  }

  Dataflow listen<E extends Event, V>(
    EventStream<E> stream,
    Operator<V> target,
    {ChangeSet Function(E)? pulse,
    V Function(E)? update,}
  ) {
    assert(isSingle([pulse, update], allowNone: true));


    if (pulse == null && update == null) {
      stream.listen((event) {
        touch(target);
      });
    } else if (pulse != null) {
      stream.listen((event) {
        this.pulse(target, pulse(event));
      });
    } else {
      stream.listen((event) {
        this.update(target, update!(event));
      });
    }

    return this;
  }
}
