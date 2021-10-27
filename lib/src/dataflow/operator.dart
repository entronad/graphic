import 'package:flutter/foundation.dart';

abstract class Operator<V> {
  Operator([
    Map<String, dynamic>? params,
    this.value,
  ]) {
    if (params != null) {
      for (var name in params.keys) {
        final source = params[name];
        if (source is Operator) {
          source.targets.add(this);
          sources[name] = source;
        } else {
          this.params[name] = source;
        }
      }
    }
  }

  @protected
  V? value;

  /// Souce operator can not be touched and can not run.
  bool get isSouce => false;

  @protected
  final params = <String, dynamic>{};

  /// Operators that params depend on.
  final Map<String, Operator> sources = {};

  /// Downstream operators in pulsing.
  final Set<Operator> targets = {};

  int rank = -1;

  /// Wheather the value should be consume after dataflow run.
  bool get consume => false;

  /// Has been runed in this pulse.
  bool runed = false;

  void _marshall() {
    for (var name in sources.keys) {
      final op = sources[name]!;
      params[name] = op.value;
    }
  }

  /// Return modified.
  bool run() {
    if (runed) {
      return false;
    }

    _marshall();
    final modified = update(evaluate());
    runed = true;
    return modified;
  }

  @protected
  V evaluate();

  @protected
  bool equalValue(V a, V b) => a == b;

  bool update(V newValue) {
    if (value != null && equalValue(value!, newValue)) {
      return false;
    }
    value = newValue;
    return true;
  }
}
