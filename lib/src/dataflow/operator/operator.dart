import 'package:meta/meta.dart';

import 'op_params.dart';
import '../pulse/pulse.dart';

var _opId = 1;

// pulse: Set<Operator> to set the source ops
const _pulseParam = 'pulse';

abstract class Operator<V> {
  Operator(
    [Map<String, dynamic>? params,
    this.value,
    bool reactive = true,]
  ) : id = _opId++ {
    if (params != null) {
      setParams(params, reactive: reactive);
    }
  }
  
  V? value;

  /// Operators that params depend on.
  final Map<String, Operator> _paramOps = {};

  @protected
  bool initOnly = false;

  @protected
  final OpParams params = OpParams();

  /// Upstream operators in pulsing.
  /// Can be entierly reset.
  Set<Operator> sources = {};

  /// Downstream operators in pulsing.
  final Set<Operator> targets = {};

  final int id;

  int clock = -1;

  int rank = -1;

  int qRank = -1;

  bool skip = false;

  bool modified = false;

  /// Recorded after run.
  /// Used in dataflow.pulse().
  /// Null means stop or skiped.
  Pulse? pulse;

  /// Returns all involved operators, including paramOps and sources
  /// The 'pulse' in params map indicates upstream operators in pushing, and has nothing to do with params.
  Set<Operator> setParams(
    Map<String, dynamic> params,
    {bool reactive = true,
    initOnly = false,}
  ) {
    final rst = <Operator>{};

    for (var name in params.keys) {
      

      if (name == _pulseParam) {
        final value = params[name] as Set<Operator>;
        for (var op in value) {
          if (op != this) {
            op.targets.add(this);
            rst.add(op);
          }
        }
        sources = value;
      } else {
        final value = params[name];
        if (value is Operator) {
          if (value != this) {
            if (reactive) {
              value.targets.add(this);
            }
            rst.add(value);
          }
          _paramOps[name] = value;
        } else {
          this.params.set(name, value);
        }
      }
    }

    marshall();
    params.clear();
    this.initOnly = initOnly;  // Only need to switch in setParams.

    return rst;
  }

  @protected
  void marshall([int clock = -1]) {
    if (_paramOps.isNotEmpty) {
      for (var name in _paramOps.keys) {
        final op = _paramOps[name];
        // A default -1 clock will ensure param set not foreced.
        final mod = op!.modified && op.clock == clock;
        params.set(name, op.value, force: mod);
      }

      if (initOnly) {
        for (var name in _paramOps.keys) {
          final op = _paramOps[name];
          op!.targets.remove(this);
        }
        _paramOps.clear();
      }
    }
  }

  Pulse? run(Pulse pulse) {
    if (pulse.clock < clock) {
      return null;
    }

    Pulse? rst;
    if (skip) {
      skip = false;
      rst = pulse;
    } else {
      rst = evaluete(pulse);
    }

    this.pulse = rst;
    return rst;
  }

  @protected
  Pulse? evaluete(Pulse pulse);

  bool set(V value) {
    if (this.value != value) {
      this.value = value;
      return true;
    } else {
      return false;
    }
  }
}
