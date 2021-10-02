import 'dart:math';

import 'package:collection/collection.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/interaction/event.dart';
import 'package:meta/meta.dart';

import 'operator.dart';

class Dataflow {
  int _currentRank = 0;

  final Set<Operator> _touched = {};

  final Set<Operator> _consumes = {};

  final Set<Operator> _runed = {};

  final HeapPriorityQueue<Operator> _heap = HeapPriorityQueue(
    (a, b) => a.rank - b.rank,
  );

  Future<Dataflow>? _running;

  O add<O extends Operator>(O op) {
    _rank(op);
    if (!op.isSouce) {
      _touch(op);
    }
    
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
      for (var target in op.targets) {
        _touch(target);
      }
    }
  }

  @protected
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

      final modified = op.run();

      _runed.add(op);

      if (modified) {
        for (var target in op.targets) {
          _enqueue(target);
        }
      }
    }

    for (var op in _consumes) {
      op.update(null);
    }

    for (var op in _runed) {
      op.runed = false;
    }

    return this;
  }

  Future<void> run() async {
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

  int listen<E extends Event, V>(
    EventSource<E> source,
    Value<V> target,
    V Function(E) update,
  ) {
    return source.on((event) {
      _update(target, update(event));
      run();
    });
  }
}
