import 'tuple.dart';
import 'pulse/pulse.dart';

class ChangeSet {
  final _add = <Tuple>[];

  final _rem = <Tuple>[];

  final _remP = <bool Function(Tuple)>{}; 

  bool reflow = false;

  ChangeSet add(List<Tuple> tuples) {
    _add.addAll(tuples);
    return this;
  }

  ChangeSet remove(
    {List<Tuple>? tuples,
    bool Function(Tuple)? filter,}
  ) {
    assert(
      (tuples != null && filter == null) ||
      (tuples == null && filter != null)
    );

    if (tuples != null) {
      _rem.addAll(tuples);
    } else {
      _remP.add(filter!);
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

    if (reflow) {
      pulse.mod = (_rem.isNotEmpty || _remP.isNotEmpty)
        ? tuples.where((t) => cur[t.id] == true).toList()
        : [...tuples];
    }

    return pulse;
  }
}
