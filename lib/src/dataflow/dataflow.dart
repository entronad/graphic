import 'dart:math';

import 'package:collection/collection.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:flutter/foundation.dart';

import 'operator.dart';

/// A dataflow graph for reactive processing of data.
class Dataflow {
  /// the current rank record for [_rank].
  int _currentRank = 0;

  /// The touched operators need to evaluate.
  final Set<Operator> _touched = {};

  /// The consume operators.
  final Set<Operator> _consumes = {};

  /// The operators has evaluated in this pulse.
  final Set<Operator> _runed = {};

  /// The evaluation heap.
  final HeapPriorityQueue<Operator> _heap = HeapPriorityQueue(
    (a, b) => a.rank - b.rank,
  );

  /// The [Future] instance when this dataflow is running.
  ///
  /// It is usefull to check whether this dataflow is running.
  Future<Dataflow>? _running;

  /// Add an operator to this dataflow.
  O add<O extends Operator>(O op) {
    _rank(op);
    if (!op.isSouce) {
      _touch(op);
    }

    if (op.consume) {
      _consumes.add(op);
    }

    assert(
      op.rank > op.sources.values.fold<int>(-1, (rank, p) => max(rank, p.rank)),
    );

    return op;
  }

  /// Sets the [Operator.rank] by the order added to this dataflow.
  void _rank(Operator op) {
    op.rank = _currentRank++;
  }

  /// Adds an operator to [_touched].
  void _touch(Operator op) {
    _touched.add(op);
  }

  /// Update an operator's value directly.
  ///
  /// It will not [run] in this method because There may need only one [run] after
  /// multiple [update]s. So remember to [run] mannually after your [update]s.
  void update<V>(
    Operator<V> op,
    V value,
  ) {
    if (op.update(value)) {
      // If operator value is modified, touches its targets.

      for (var target in op.targets) {
        _touch(target);
      }
    }
  }

  /// Evaluates the touched operators.
  ///
  /// This is used by [run].
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

  /// Evaluates this dataflow.
  Future<void> run() async {
    while (_running != null) {
      await _running;
    }

    _running = evaluate().then(
      (_) {
        _running = null;
        return this;
      },
      onError: (error) {
        _running = null;
        throw error;
      },
    );
  }

  /// Enqueues an operator to the evaluation heap.
  void _enqueue(Operator op) {
    _heap.add(op);
  }

  /// Registers an [Value] operator to listen to an [SignalSource].
  int listen<S extends Signal, V>(
    SignalSource<S> source,
    Value<V> target,
    V Function(S) updater,
  ) {
    return source.on((event) {
      update(target, updater(event));
      run();
    });
  }
}
