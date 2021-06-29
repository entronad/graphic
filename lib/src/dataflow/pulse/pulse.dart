import 'package:flutter/material.dart';
import 'package:graphic/src/util/mask.dart' as mask_util;

import '../dataflow.dart';
import '../tuple.dart';

abstract class PulseFlags {
  static const add = 1 << 0;
  static const rem = 1 << 1;
  static const mod = 1 << 2;
  static const all = add | rem | mod;
  static const reflow = 1 << 3;  /// All tuples in source except for the add, rem and mod tuples.
  static const source = 1 << 4;  /// A 'pass-through' to a backing data source, wheather or not in add, rem and mod tuples.
  static const modFields = 1<< 5;
}

// Null means falsy.
typedef TupleFilter = Tuple? Function(Tuple);

typedef TupleVisitor = void Function(Tuple);

void _visitTuples(
  List<Tuple> tuples,
  TupleVisitor visitor,
  [TupleFilter? filter,]
) {
  if (filter != null) {
    for (var tuple in tuples) {
      final t = filter(tuple);
      if (t != null) {
        visitor(t);
      }
    }
  } else {
    tuples.forEach(visitor);
  }
}

List<Tuple> _materializeTuples(
  List<Tuple> tuples,
  [TupleFilter? filter,]
) {
  final rst = <Tuple>[];
  _visitTuples(tuples, (tuple) { rst.add(tuple); }, filter);
  return rst;
}

TupleFilter _appendFilter(TupleFilter? a, TupleFilter b) =>
  (a != null)
    ? (t) => a(t) ?? b(t)
    : b;

class Pulse {
  Pulse(
    this.dataflow,
    [this.clock = -1]
  );

  // only for this and MultiPulse
  @protected
  Pulse.from(
    Pulse src,
    int flags,
  ) : dataflow = src.dataflow,
      clock = src.clock {
    if (mask_util.contain(flags, PulseFlags.modFields)) {
      modFields = src.modFields;
    }

    if (mask_util.contain(flags, PulseFlags.add)) {
      add = src.add;
      addF = src.addF;
    }

    if (mask_util.contain(flags, PulseFlags.mod)) {
      mod = src.mod;
      modF = src.modF;
    }

    if (mask_util.contain(flags, PulseFlags.rem)) {
      rem = src.rem;
      remF = src.remF;
    }

    if (mask_util.contain(flags, PulseFlags.source)) {
      source = src.source;
      sourceF = src.sourceF;
    }
  }

  final Dataflow dataflow;

  final int clock;

  List<Tuple> add = [];

  List<Tuple> mod = [];

  List<Tuple> rem = [];

  // There could be no source.
  List<Tuple>? source;

  TupleFilter? addF;

  TupleFilter? remF;

  TupleFilter? modF;

  TupleFilter? sourceF;

  Set<String> modFields = {};

  Pulse fork(
    [int flags = PulseFlags.source | PulseFlags.modFields]  // By default, only copy source and modFields.
  ) => Pulse.from(this, flags);

  Pulse clone() {
    final pulse = fork(PulseFlags.all | PulseFlags.source | PulseFlags.modFields);
    pulse.add = [...pulse.add];
    pulse.rem = [...pulse.rem];
    pulse.mod = [...pulse.mod];
    if (pulse.source != null) {
      pulse.source = [...pulse.source!];
    }
    return pulse.materialize(PulseFlags.all | PulseFlags.source);
  }

  Pulse materialize([int flags = PulseFlags.all]) {
    if (mask_util.contain(flags, PulseFlags.add) && addF != null) {
      add = _materializeTuples(add, addF!);
      addF = null;
    }
    if (mask_util.contain(flags, PulseFlags.rem) && remF != null) {
      rem = _materializeTuples(rem, remF!);
      remF = null;
    }
    if (mask_util.contain(flags, PulseFlags.mod) && modF != null) {
      mod = _materializeTuples(mod, modF!);
      modF = null;
    }
    if (mask_util.contain(flags, PulseFlags.source) && sourceF != null) {
      if (source != null) {
        source = _materializeTuples(source!, sourceF!);
      }
      sourceF = null;
    }
    return this;
  }

  bool changed([int flags = PulseFlags.all]) =>
    (mask_util.contain(flags, PulseFlags.add) && add.isNotEmpty) ||
    (mask_util.contain(flags, PulseFlags.mod) && mod.isNotEmpty) ||
    (mask_util.contain(flags, PulseFlags.rem) && rem.isNotEmpty);
  
  Pulse reflow({bool fork = false}) {
    if (fork) {
      return this
        .fork(PulseFlags.all | PulseFlags.source | PulseFlags.modFields)
        .reflow();
    }

    final addLen = add.length;
    final sourceLen = source?.length;
    if (sourceLen != null && sourceLen != addLen) {
      mod = source!;
      if (addLen != 0) {
        addFilter(PulseFlags.mod, _getContainFilter(PulseFlags.add));
      }
    }
    return this;
  }

  Pulse modify(Set<String> fields) {
    modFields.addAll(fields);
    return this;
  }

  bool modified([Set<String>? fields, bool noMod = false]) {
    if (!((noMod || mod.isNotEmpty) && modFields.isNotEmpty)) {
      return false;
    }
    if (fields == null) {
      return modFields.isNotEmpty;
    }
    return fields.any((field) => modFields.contains(field));
  }

  Pulse addFilter(int flags, TupleFilter filter) {
    if (mask_util.contain(flags, PulseFlags.add)) {
      addF = _appendFilter(addF, filter);
    }
    if (mask_util.contain(flags, PulseFlags.rem)) {
      remF = _appendFilter(remF, filter);
    }
    if (mask_util.contain(flags, PulseFlags.mod)) {
      modF = _appendFilter(modF, filter);
    }
    if (mask_util.contain(flags, PulseFlags.source)) {
      sourceF = _appendFilter(sourceF, filter);
    }
    return this;
  }

  TupleFilter _getContainFilter(int flags) {
    final ids = <int>{};
    visit(flags, (t) { ids.add(t.id); });
    return (tuple) => (ids.contains(tuple.id)) ? null : tuple;
  }

  Pulse visit(int flags, TupleVisitor visitor) {
    if (mask_util.contain(flags, PulseFlags.source) && source != null) {
      _visitTuples(source!, visitor, sourceF);
      return this;
    }

    if (mask_util.contain(flags, PulseFlags.add)) {
      _visitTuples(add, visitor, addF);
    }
    if (mask_util.contain(flags, PulseFlags.rem)) {
      _visitTuples(rem, visitor, remF);
    }
    if (mask_util.contain(flags, PulseFlags.mod)) {
      _visitTuples(mod, visitor, modF);
    }

    if (mask_util.contain(flags, PulseFlags.reflow) && source != null) {
      final sum = add.length + mod.length;
      if (sum == source!.length) {
        
      } else if (sum != 0) {
        _visitTuples(source!, visitor, _getContainFilter(PulseFlags.add | PulseFlags.mod));
      } else {
        _visitTuples(source!, visitor, sourceF);
      }
    }

    return this;
  }

  Pulse runAfter(
    Hook postrun,
    {int priority = 0,}
  ) {
    dataflow.runAfter(postrun, priority: priority);
    return this;
  }
}
