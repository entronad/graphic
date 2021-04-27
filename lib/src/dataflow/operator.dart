import 'package:graphic/src/util/mask.dart' as mask_util;

import 'parameters.dart';
import 'pulse.dart';

var _opId = 0;

final _noParameters = Parameters();

const _skipFlag = 1;
const _modifiedFlag = 2;

typedef OperatorUpdate<V, D> = V Function(Operator<V, D>, Parameters, Pulse<D>);

class _ArgOpsInfo<V, D> {
  _ArgOpsInfo(
    this.name,
    this.index,
    this.op,
  );

  final String name;
  final int? index;
  final Operator<V, D> op;
}

class Operator<V, D> {
  Operator(
    [V? init,
    OperatorUpdate<V, D>? update,
    Parameters? parameters,
    bool react = true,]
  ) : id = ++ _opId,
      value = init,
      _update = update {
    if (parameters != null) {
      this.parameters(parameters, react);
    }
  }

  int id;
  V? value;
  int clock = -1;
  int rank = -1;
  int qRank = -1;
  int flags = 0;
  OperatorUpdate<V, D>? _update;
  Set<Operator<dynamic, D>>? _targets;
  Parameters? _argVal;
  List<_ArgOpsInfo<dynamic, D>>? _argOps;
  bool _argOpsInitOnly = false;
  List<Operator<dynamic, D>>? source;
  Pulse<D>? pulse;

  bool get hasTargets => _targets != null;

  Set<Operator<dynamic, D>> get targets => _targets ?? {};

  bool set(V value) {
    if (this.value != value) {
      this.value = value;
      return true;
    } else {
      return false;
    }
  }

  bool get skip => mask_util.contain(flags, _skipFlag);

  set skip(bool value) =>
    flags = value ? (flags | _skipFlag) : (flags & ~_skipFlag);
  
  bool get modified => mask_util.contain(flags, _modifiedFlag);

  set modified(bool value) =>
    flags = value ? (flags | _modifiedFlag) : (flags & ~_modifiedFlag);
  
  List<Operator<dynamic, D>> parameters(
    Parameters parameters,
    [bool react = true,
    initOnly = false,]
  ) {
    if (_argVal == null) {
      _argVal = Parameters();
    }
    if (_argOps == null) {
      _argOps = [];
      _argOpsInitOnly = false;
    }
    final deps = <Operator<dynamic, D>>[];

    for (var name in parameters.values.keys) {
      final value = parameters.values[name]!;

      final _add = (String name, int? index, Object value) {
        if (value is Operator<dynamic, D>) {
          if (value != this) {
            if (react) {
              value.targets.add(this);
            }
            deps.add(value);
          }
          _argOps!.add(_ArgOpsInfo(name, index, value));
        } else {
          if (index != null) {
            _argVal!.setListItem(name, index, value);
          } else {
            _argVal!.set(name, value);
          }
        }
      };

      if (name == 'pulse') {
        final ops = (value is List<Operator<dynamic, D>>) ? value : [value as Operator<dynamic, D>];
        for (var op in ops) {
          if (op != this) {
            op.targets.add(this);
            deps.add(op);
          }
        }
        source = ops;
      } else if (value is List) {
        _argVal!.set(name, []);
        for (var i = 0; i < value.length; i++) {
          _add(name, i, value[i]);
        }
      } else {
        _add(name, null, value);
      }
    }

    marshall().clear();
    if (initOnly) {
      _argOpsInitOnly = true;
    }

    return deps;
  }

  Parameters marshall([int? clock]) {
    if (_argVal == null) {
      _argVal = _noParameters;
    }

    if (_argOps != null) {
      for (var item in _argOps!) {
        final op = item.op;
        final mod = op.modified && op.clock == clock;
        final index = item.index;
        if (index != null) {
          _argVal!.setListItem(item.name, index, op.value, mod);
        } else {
          _argVal!.set(item.name, op.value, mod);
        }
      }

      if (_argOpsInitOnly) {
        for (var item in _argOps!) {
          item.op.targets.remove(this);
        }
        _argOps = null;
        _argOpsInitOnly = false;
        _update = null;
      }
    }

    return _argVal!;
  }

  void detach() {
    if (_argOps != null) {
      for (var item in _argOps!) {
        final op = item.op;
        if (op._targets != null) {
          op._targets!.remove(this);
        }
      }
    }
  }

  Pulse<D>? evaluate(Pulse<D> pulse) {
    if (_update != null) {
      final parameters = marshall(pulse.clock);
      final v = _update!(this, parameters, pulse);

      parameters.clear();
      if (v != value) {
        value = v;
        return null;
      } else {
        return Pulse<D>.stopPropagation();
      }
    }
  }

  Pulse<D>? run(Pulse<D> pulse) {
    if (pulse.clock < clock) {
      return Pulse<D>.stopPropagation();
    }

    if (skip) {
      skip = false;
      this.pulse = null;
      return null;
    } else {
      this.pulse = evaluate(pulse) ?? pulse;
      return this.pulse;
    }
  }
}
