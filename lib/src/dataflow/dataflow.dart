import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
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
    if (op.runInit) {
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
  /// An operator can only be updated by it's channel.
  void _update<V>(
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

  /// Initially calculate this dataflow.
  ///
  /// This is used by [run] in initialization.
  @protected
  Future<Dataflow> init() async {
    // Which operators to run in initialization is only determined by Whether it's
    // a start (runInit is false).
    for (var op in _touched) {
      op.run();
    }

    return this;
  }

  /// Evaluates the touched operators.
  ///
  /// This is used by [run].
  @protected
  Future<Dataflow> evaluate() async {
    for (var op in _touched) {
      _enqueue(op);
    }
    _touched.clear();

    while (_heap.isNotEmpty) {
      final op = _heap.removeFirst();

      final updated = op.run();

      _runed.add(op);

      if (updated) {
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
  ///
  /// Call this method only when initialization or any operator is touched.
  Future<void> run({bool init = false}) async {
    while (_running != null) {
      await _running;
    }

    final rst = init ? this.init() : evaluate();

    _running = rst.then(
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

  /// Binds a channel to an operator.
  ///
  /// The channels are the only way to communicate with outside for this dataflow.
  ///
  /// An operator can only be binded to one channel.
  ///
  /// The value changed to null will also trigger a communication. But the consume
  /// operator's value turning to null after running will not.
  void bindChannel<V>(
    StreamController<V?> channel,
    Operator<V> target,
  ) {
    assert(target.channel == null);
    channel.stream.listen((value) {
      _update(target, value);
      run();
    });
    target.channel = channel;
  }
}
