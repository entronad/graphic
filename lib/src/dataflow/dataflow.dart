import 'dart:math';

import 'package:collection/collection.dart';
import 'package:graphic/src/dataflow/event_stream.dart';
import 'package:graphic/src/interaction/event.dart';

import 'operator.dart';

class Dataflow {
  int _currentRank = 0;

  final Set<Operator> _touched = {};

  final Set<Operator> _consumes = {};

  final HeapPriorityQueue<Operator> _heap = HeapPriorityQueue(
    (a, b) => a.rank - b.rank,
  );

  Future<Dataflow>? _running;

  Operator<V> add<V>(Operator<V> op) {
    _rank(op);
    _touch(op);

    if (op.consume) {
      _consumes.add(op);
    }

    assert(op.rank > op.sources.values.fold<int>(
      -1,
      (rank, p) => max(rank, p.rank)),
    );

    return op;
  }

  void _rank(Operator op) {
    // Start form 0, like list index.
    op.rank = _currentRank++;
  }

  void _touch(Operator op) {
    _touched.add(op);
  }

  /// Operator value cannot update directly outside the dataflow.
  /// It can only be updatede by event streams.
  /// Whe updated, rerun starts form it's targets.
  void _update<V>(
    Operator<V> op,
    V value,
  ) {
    if (op.update(value)) {
      _touch(op);
    }
  }

  Future<Dataflow> evaluate() async {
    if (_touched.isEmpty) {
      return this;
    }

    for (var op in _touched) {
      _enqueue(op);
    }
    _touched.clear();

    while (_heap.isNotEmpty) {
      final op = _heap.removeFirst();

      final next = op.run();

      if (next) {
        for (var target in op.targets) {
          _enqueue(target);
        }
      }
    }

    for (var op in _consumes) {
      op.update(null);
    }

    return this;
  }

  void run() async {
    while (_running != null) {
      await _running;
    }

    _running = evaluate().then(
      (_) {_running = null; return this;},
      onError:  (error) {_running = null; throw error;},
    );
  }

  void _enqueue(Operator op) {
    _heap.add(op);
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

  /// Register a event stream to update a value keeper operator.
  void listen<E extends Event, V>(
    EventStream<E> stream,
    Operator<V> target,
    V Function(E) update,
  ) {
    stream.listen((event) {
      this._update(target, update(event));
    });
  }
}
