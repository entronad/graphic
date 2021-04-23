import 'dart:async';

import 'package:graphic/src/dataflow/util/asyncCallback.dart';

import 'operator.dart';
import 'pulse.dart';
import 'multi_pulse.dart';
import 'parameters.dart';
import 'changeset.dart';
import 'tuple.dart';
import 'util/heap.dart';

Dataflow<D> _reentrant<D>(Dataflow<D> df) {
  df.error('Dataflow already running. Use runAsync() to chain invocations.');
  return df;
}

typedef DataflowCallback<D> = FutureOr<void> Function(Dataflow<D>);

class _CallbackInfo<D> {
  _CallbackInfo(this.callback, this.priority);

  final DataflowCallback<D> callback;
  final int priority;
}

class Dataflow<D> {
  static const cleanThreshold = 1e4;

  int _clock = 0;
  int _rank = 0;

  Set<Operator<dynamic, D>> _touched = {};
  Map<int, Pulse<D>> _input = {};
  Pulse<D>? _pulse;

  Heap<Operator<dynamic, D>> _heap = Heap(
    (a, b) => a.qRank - b.qRank
  );
  List<_CallbackInfo<D>> _postrun = [];

  Future<Dataflow<D>>? _running;

  int get clock => _clock;

  // TODO: implement logger

  void error(String message) {}

  void warn(String message) {}

  void info(String message) {}

  void debug(String message) {}

  Operator<dynamic, D> add(
    Operator<dynamic, D> op,
    [Parameters? parameters,
    bool react = true,]
  ) {
    rank(op);
    if (parameters != null) {
      connect(op, op.parameters(parameters, react));
    }
    touch(op);

    return op;
  }

  void connect(
    Operator<dynamic, D> target,
    List<Operator<dynamic, D>> sources,
  ) {
    for (var source in sources) {
      if (target.rank < source.rank) {
        rerank(target);
        return;
      }
    }
  }

  void rank(Operator<dynamic, D> op) {
    op.rank = ++_rank;
  }

  void rerank(Operator<dynamic, D> op) {
    final queue = [op];

    while (queue.isNotEmpty) {
      var cur = queue.removeLast();
      rank(cur);
      if (cur.hasTargets) {
        final targets = cur.targets.toList();
        for (var i = targets.length; --i >= 0;) {
          cur = targets[i];
          queue.add(cur);
          if (cur == op) {
            throw ArgumentError('Cycle detected in dataflow graph.');
          }
        }
      }
    }
  }

  Dataflow<D> pulse(
    Operator<dynamic, D> op,
    Changeset<D> changeset,
    {bool skip = false,
    bool force = false,}
  ) {
    touch(op, skip: skip, force: force);

    final p = Pulse(this, clock + (_pulse != null ? 0 : 1));
    final t = (op.pulse?.source ?? <Tuple<D>>[]) as List<Tuple<D>>;

    p.target = op;
    _input[op.id] = changeset.pulse(p, t);

    return this;
  }

  Dataflow<D> touch(
    Operator<dynamic, D> op,
    {bool skip = false,
    bool force = false,}
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

  Dataflow<D> update<V>(
    Operator<V, D> op,
    V value,
    {bool skip = false,
    bool force = false,}
  ) {
    if (op.set(value) || force) {
      touch(op, skip: skip, force: force);
    }

    return this;
  }

  Changeset<D> changeset() => Changeset<D>();

  Dataflow<D> ingest<V>(Operator<V, D> target, List<Tuple<D>> data) =>
    pulse(target, changeset().insert(data));
  
  // TODO: event

  Future<Dataflow<D>> evaluate(
    String? encode,
    [DataflowCallback<D>? prerun,
    DataflowCallback<D>? postrun,]
  ) async {
    if (_pulse != null) {
      return _reentrant(this);
    }

    if (prerun != null) {
      await asyncCallback(this, prerun);
    }

    if (_touched.isEmpty) {
      debug('Dataflow invoked, but nothing to do.');
      return this;
    }

    final clock = ++_clock;

    _pulse = Pulse(this, clock, encode);

    for (var op in _touched) {
      _enqueue(op, true);
    }
    _touched = {};

    var count = 0;
    var errorMessage;
    final asyncs = <Future<DataflowCallback<D>>>[];

    try {
      while (_heap.size > 0) {
        final op = _heap.pop();

        if (op.rank != op.qRank) {
          _enqueue(op, true);
          continue;
        }

        var next = op.run(_getPulse(op, encode));

        if (next?.then != null) {
          // next = await next;
        } else if (next?.async != null) {
          asyncs.add(next!.async!);
          next = Pulse<D>.stopPropagation();
        }

        if (next == null || next.stopPropagation) {
          if (op.hasTargets) {
            for (var op in op.targets) {
              _enqueue(op);
            }
          }
        }

        ++count;
      }
    } catch (e) {
      _heap.clear();
      errorMessage = e.toString();
    }

    _input = {};
    _pulse = null;

    debug('Pulse $_clock: $count operators');

    if (errorMessage != null) {
      _postrun = [];
      error(errorMessage);
    }

    if (_postrun.isNotEmpty) {
      final pr = _postrun..sort((a, b) => b.priority - a.priority);
      _postrun = [];
      for (var callbackInfo in pr) {
        await asyncCallback(this, callbackInfo.callback);
      }
    }

    if (postrun != null) {
      await asyncCallback(this, postrun);
    }

    if (asyncs.isNotEmpty) {
      Future.wait(asyncs).then(
        (callbacks) { runAsync(null, (df) {
          for (var callback in callbacks) {
            try {
              callback(df);
            } catch (e) {
              df.error(e.toString());
            }
          }
        }); }
      );
    }

    return this;
  }

  Dataflow<D> run(
    String? encode,
    [DataflowCallback<D>? prerun,
    DataflowCallback<D>? postrun,]
  ) {
    if (_pulse != null) {
      return _reentrant(this);
    }
    evaluate(encode, prerun, postrun);

    return this;
  }

  Future<Dataflow<D>> runAsync(
    String? encode,
    [DataflowCallback<D>? prerun,
    DataflowCallback<D>? postrun,]
  ) async {
    while (_running != null) {
      await _running;
    }
    
    final _clear = (Dataflow<D> df) { df._running = null; };
    _running = evaluate(encode, prerun, postrun);
    _running!.then(_clear, onError: _clear);

    return _running!;
  }

  void runAfter(
    DataflowCallback<D> callback,
    [bool enqueue = false,
    int priority = 0,]
  ) {
    if (_pulse != null || enqueue) {
      _postrun.add(_CallbackInfo(callback, priority));
    } else {
      try {
        callback(this);
      } catch (e) {
        error(e.toString());
      }
    }
  }

  void _enqueue(Operator<dynamic, D> op, [bool force = false]) {
    final q = op.clock < _clock;
    if (q) {
      op.clock = _clock;
    }
    if (q || force) {
      op.qRank = op.rank;
      _heap.push(op);
    }
  }

  Pulse<D> _getPulse(Operator<dynamic, D> op, String? encode) {
    final s = op.source;
    return (s != null && s.length >= 2)
      ? MultiPulse(this, _clock, s.map((o) => o.pulse!).toList(), encode)
      : _input[op.id] ?? _singlePulse(_pulse!, s?.first.pulse);
  }

  Pulse<D> _singlePulse(Pulse<D> p, Pulse<D>? s) {
    if (s != null && s.clock == p.clock) {
      return s;
    }

    p = p.fork();
    if (s != null && !s.stopPropagation) {
      p.source = s.source;
    }
    return p;
  }
}
