import 'package:meta/meta.dart';

abstract class Operator<V> {
  Operator(
    [Map<String, dynamic>? params,
    this.value,]
  ) {
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

  /// Wheather the value should be consume after dataflow run.
  bool get consume => false;

  @protected
  V? value;

  @protected
  final params = <String, dynamic>{};

  /// Operators that params depend on.
  final Map<String, Operator> sources = {};

  /// Downstream operators in pulsing.
  final Set<Operator> targets = {};

  int rank = -1;

  void _marshall() {
    for (var name in sources.keys) {
      final op = sources[name]!;
      params[name] = op.value;
    }
  }

  /// Return modified.
  bool run() {
    _marshall();
    return update(evaluate());
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
