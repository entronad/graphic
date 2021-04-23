import 'package:graphic/src/dataflow/pulse.dart';

import 'tuple.dart';

typedef _ValueModifier<D> = D Function(D);

class _ModInfo<D> {
  _ModInfo(this.tuple, {this.value, this.field})
    : assert((value == null && field != null)
      || (value != null && field == null));

  final Tuple<D> tuple;

  final _ValueModifier<D>? value;
  final String? field;
}

class _ModPInfo<D> {
  _ModPInfo(this.filter, {this.value, this.field})
    : assert((value == null && field != null)
      || (value != null && field == null));

  final Predicate<D> filter;

  final _ValueModifier<D>? value;
  final String? field;
}

class Changeset<D> {
  final _add = <Tuple<D>>[];
  final _rem = <Tuple<D>>[];
  final _mod = <_ModInfo<D>>[];
  final _remP = <Predicate<D>>[];
  final _modP = <_ModPInfo<D>>[];
  bool? _clean;
  bool _reflow = false;

  Changeset<D> insert(List<Tuple<D>> data) {
    for (var tuple in data) {
      _add.add(tuple);
    }
    return this;
  }

  Changeset<D> remove(List<Tuple<D>> data) {
    for (var tuple in data) {
      _rem.add(tuple);
    }
    return this;
  }

  Changeset<D> removeP(List<Predicate<D>> filters) {
    for (var filter in filters) {
      _remP.add(filter);
    }
    return this;
  }

  Changeset<D> modify(Tuple<D> tuple, _ValueModifier<D> value) {
    _mod.add(_ModInfo(tuple, value: value));
    return this;
  }

  Changeset<D> modifyP(Predicate<D> filter, _ValueModifier<D> value) {
    _modP.add(_ModPInfo(filter, value: value));
    return this;
  }

  Changeset<D> encode(Tuple<D> tuple, String set) {
    _mod.add(_ModInfo(tuple, field: set));
    return this;
  }

  Changeset<D> encodeP(Predicate<D> filter, String set) {
    _modP.add(_ModPInfo(filter, field: set));
    return this;
  }

  Changeset<D> clean(bool value) {
    _clean = value;
    return this;
  }

  Changeset<D> reflow() {
    _reflow = true;
    return this;
  }

  Pulse<D> pulse(Pulse<D> pulse, List<Tuple<D>> tuples) {
    final cur = <int, bool>{};

    for (var tuple in tuples) {
      cur[tuple.id] = true;
    }

    for (var t in _rem) {
      cur[t.id] = false;
    }

    for (var f in _remP) {
      for (var t in tuples) {
        if (f(t)) {
          cur[t.id] = false;
        }
      }
    }

    for (var t in _add) {
      final id = t.id;
      if (cur[id] != null) {
        cur[id] = true;
      } else {
        pulse.add.add(Tuple(t.datum));
      }
    }

    for (var t in tuples) {
      if (cur[t.id] = false) {
        pulse.rem.add(t);
      }
    }

    final rst = <int, Tuple<D>>{};

    final _modify = (Tuple<D> t, String? f, _ValueModifier<D>? v) {
      if (v != null) {
        t.datum = v(t.datum);
      } else {
        pulse.encode = f;
      }

      if (!_reflow) {
        rst[t.id] = t;
      }
    };

    for (var m in _mod) {
      final t = m.tuple;
      final f = m.field;
      final state = cur[t.id];
      if (state == true) {
        _modify(t, f, m.value);
        pulse.modify();
      }
    }

    for (var m in _modP) {
      final f = m.filter;
      for (var t in tuples) {
        if (f(t) && cur[t.id] == true) {
          _modify(t, m.field, m.value);
        }
      }
      pulse.modify();
    }

    if (_reflow) {
      pulse.mod = (_rem.isNotEmpty || _remP.isNotEmpty)
        ? tuples.where((t) => (cur[t.id] == true)).toList()
        : [...tuples];
    } else {
      for (var t in rst.values) {
        pulse.mod.add(t);
      }
    }

    if (
      _clean == true
        || _clean == null
        && (_rem.isNotEmpty || _remP.isNotEmpty)
    ) {
      pulse.clean = true;
    }

    return pulse;
  }
}
