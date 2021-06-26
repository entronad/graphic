import 'package:flutter/material.dart';

import 'op_params.dart';
import '../pulse/pulse.dart';

var _opId = 1;

// pulse: Set<Operator> to set the source ops
const _pulseParam = 'pulse';

abstract class Operator<V> {
  Operator(
    this.value,
    [Map<String, dynamic>? params,
    bool react = true,]
  ) : id = _opId++ {
    if (params != null) {
      setParams(params, react);
    }
  }
  
  V value;

  /// Operators that params depend on.
  final Map<String, Operator> _paramOps = {};

  @protected
  bool initOnly = false;

  final OpParams _params = OpParams();

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
  Set<Operator> setParams(
    Map<String, dynamic> params,
    [bool react = true,
    initOnly = false,]
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
            if (react) {
              value.targets.add(this);
            }
            rst.add(value);
          }
          _paramOps[name] = value;
        } else {
          _params.set(name, value);
        }
      }
    }

    marshall().clear();
    initOnly = initOnly;  // Only need to switch in setParams.

    return rst;
  }

  @protected
  OpParams marshall([int clock = -1]) {
    if (_paramOps.isNotEmpty) {
      for (var name in _paramOps.keys) {
        final op = _paramOps[name];
        // A default -1 clock will ensure param set not foreced.
        final mod = op!.modified && op.clock == clock;
        _params.set(name, op.value, force: mod);
      }

      if (initOnly) {
        for (var name in _paramOps.keys) {
          final op = _paramOps[name];
          op!.targets.remove(this);
        }
        _paramOps.clear();
      }
    }
    return _params;
  }

  Pulse? run(Pulse pulse) {
    if (pulse.clock < clock) {
      return null;
    }

    if (skip) {
      skip = false;
      this.pulse = pulse;
      return pulse;
    } else {
      return evaluete(pulse);
    }
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
