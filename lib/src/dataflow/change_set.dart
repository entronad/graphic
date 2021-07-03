import 'package:graphic/src/util/assert.dart';

import 'tuple.dart';
import 'pulse/pulse.dart';

class _ModInfo {
  _ModInfo(this.fields, this.modify);

  final Set<String> fields;

  final TupleVisitor modify;
}

class ChangeSet {
  final _add = <Tuple>[];

  final _mod = <Tuple, _ModInfo>{};

  final _modP = <TuplePredicate, _ModInfo>{};

  final _rem = <Tuple>[];

  final _remP = <TuplePredicate>{};

  bool reflow = false;

  ChangeSet add(List<Tuple> tuples) {
    _add.addAll(tuples);
    return this;
  }

  ChangeSet remove(
    {List<Tuple>? tuples,
    TuplePredicate? filter,}
  ) {
    assert(isSingle([tuples, filter]));

    if (tuples != null) {
      _rem.addAll(tuples);
    } else {
      _remP.add(filter!);
    }
    return this;
  }

  ChangeSet modify(
    {List<Tuple>? tuples,
    TuplePredicate? filter,
    required Set<String> fields,
    required TupleVisitor modify,}
  ) {
    assert(isSingle([tuples, filter]));

    if (tuples != null) {
      final info = _ModInfo(fields, modify);
      for (var tuple in tuples) {
        _mod[tuple] = info;
      }
    } else {
      _modP[filter!] = _ModInfo(fields, modify);
    }
    return this;
  }

  Pulse pulse(Pulse pulse, List<Tuple> tuples) {
    // {id: available}
    final cur = <int, bool>{};

    for (var tuple in tuples) {
      cur[tuple.id] = true;
    }

    for (var rt in _rem) {
      cur[rt.id] = false;
    }

    for (var rp in _remP) {
      for (var tuple in tuples) {
        if (rp(tuple)) {
          cur[tuple.id] = false;
        }
      }
    }

    for (var at in _add) {
      if (cur[at.id] != null) {
        cur[at.id] = true;
      } else {
        pulse.add.add(at);
      }
    }

    for (var tuple in tuples) {
      if (cur[tuple.id] == false) {
        pulse.rem.add(tuple);
      }
    }

    // Ensure unique.
    final modTmp = <Tuple>{};

    final modifyTuple = (Tuple tuple, _ModInfo info) {
      info.modify(tuple);
      pulse.modify(info.fields);
      if (!reflow) {
        modTmp.add(tuple);
      }
    };

    for (var mt in _mod.keys) {
      if (cur[mt.id] == true) {
        modifyTuple(mt, _mod[mt]!);
      }
    }

    for (var mp in _modP.keys) {
      for (var tuple in tuples) {
        if (mp(tuple) && cur[tuple.id] == true) {
          modifyTuple(tuple, _modP[mp]!);
        }
      }
    }

    if (reflow) {
      pulse.mod = (_rem.isNotEmpty || _remP.isNotEmpty)
        ? tuples.where((t) => cur[t.id] == true).toList()
        : [...tuples];
    } else {
      pulse.mod.addAll(modTmp);
    }

    return pulse;
  }
}
