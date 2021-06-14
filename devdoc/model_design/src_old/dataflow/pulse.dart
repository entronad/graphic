import 'package:graphic/src/util/mask.dart' as mask_util;

import 'tuple.dart';
import 'dataflow.dart';
import 'operator.dart';

abstract class PulseVisitType {
  static const add = 1 << 0;
  static const rem = 1 << 1;
  static const mod = 1 << 2;
  static const addRem = add | rem;
  static const addMod = add | mod;
  static const all = add | rem | mod;
  static const reflow = 1 << 3;
  static const source = 1 << 4;
  static const noSource = 1 << 5;
  static const noFields = 1 << 6;
}

typedef TupleFilter<D> = Tuple<D>? Function(Tuple<D>);

typedef TupleVisitor<D> = void Function(Tuple<D>);

void _visitTupleList<D>(
  List<Tuple<D>> list,
  TupleFilter<D>? filter,
  TupleVisitor<D> visitor,
) {
  if (filter != null) {
    for (var tuple in list) {
      final t = filter(tuple);
      if (t != null) {
        visitor(t);
      }
    }
  } else {
    list.forEach(visitor);
  }
}

List<Tuple<D>> _materialize<D>(List<Tuple<D>> data, TupleFilter<D> filter) {
  final rst = <Tuple<D>>[];
  _visitTupleList<D>(data, filter, (tuple) { rst.add(tuple); });
  return rst;
}

TupleFilter<D> _filter<D>(Pulse<D> pulse, int flags) {
  final map = <int, int>{};
  pulse.visit(flags, (t) { map[t.id] = 1; });
  return (t) => (map[t.id] != null) ? null : t;
}

TupleFilter<D> _addFilter<D>(TupleFilter<D>? a, TupleFilter<D> b) =>
  (a != null)
    ? (t) => a(t) ?? b(t)
    : b;

class Pulse<D> {
  Pulse(
    this.dataflow,
    [this.clock = -1,
    this.encode,]
  ) : _stopPropagation = false;

  Pulse.stopPropagation()
    : _stopPropagation = true,
      dataflow = Dataflow<D>(),
      clock = -1;
  
  final bool _stopPropagation;

  Dataflow<D> dataflow;
  int clock;
  String? encode;
  List<Tuple<D>> add = [];
  List<Tuple<D>> rem = [];
  List<Tuple<D>> mod = [];
  List<Tuple<D>>? source;
  TupleFilter<D>? addF;
  TupleFilter<D>? remF;
  TupleFilter<D>? modF;
  TupleFilter<D>? sourceF;
  bool fields = false;
  bool clean = false;

  Pulse<D> Function(void Function(Pulse<D>))? then;
  Operator<dynamic, D>? target;
  Future<DataflowCallback<D>>? async;

  bool get stopPropagation => _stopPropagation;

  Pulse<D> fork([int flags = 0]) =>
    Pulse(dataflow).init(this, flags);

  Pulse<D> clone() {
    final p = fork(PulseVisitType.all);
    p.add = [...p.add];
    p.rem = [...p.rem];
    p.mod = [...p.mod];
    if (p.source != null) {
      p.source = [...p.source!];
    }
    return p.materialize(PulseVisitType.all | PulseVisitType.source);
  }

  Pulse<D> addAll() {
    var p = this;
    final reuse = (p.source == null)
      || p.add == p.rem
      || (p.rem.length == 0 && p.source!.length == p.add.length);
    
    if (reuse) {
      return p;
    } else {
      p = Pulse(dataflow).init(this, 0);
      p.add = p.source!;
      p.rem = [];
      return p;
    }
  }

  Pulse<D> init(Pulse<D> src, int flags) {
    this.clock = src.clock;
    this.encode = src.encode;

    if (
      src.fields &&
      mask_util.contain(flags, PulseVisitType.noFields)
    ) {
      this.fields = src.fields;
    }

    if (mask_util.contain(flags, PulseVisitType.add)) {
      this.addF = src.addF;
      this.add = src.add;
    } else {
      this.addF = null;
      this.add = [];
    }

    if (mask_util.contain(flags, PulseVisitType.rem)) {
      this.remF = src.remF;
      this.rem = src.rem;
    } else {
      this.remF = null;
      this.rem = [];
    }

    if (mask_util.contain(flags, PulseVisitType.mod)) {
      this.modF = src.modF;
      this.mod = src.mod;
    } else {
      this.modF = null;
      this.mod = [];
    }

    if (mask_util.contain(flags, PulseVisitType.noSource)) {
      this.sourceF = null;
      this.source = null;
    } else {
      this.sourceF = src.sourceF;
      this.source = src.source;
      if (src.clean) {
        this.clean = src.clean;
      }
    }

    return this;
  }

  void runAfter(DataflowCallback<D> callback) {
    dataflow.runAfter(callback);
  }

  bool changed([int? flags]) {
    final f = flags ?? PulseVisitType.all;
    return (mask_util.contain(f, PulseVisitType.add) && add.length != 0)
      || (mask_util.contain(f, PulseVisitType.rem) && rem.length != 0)
      || (mask_util.contain(f, PulseVisitType.mod) && mod.length != 0);
  }

  Pulse<D> reflow([bool fork = false]) {
    if (fork) {
      return this.fork(PulseVisitType.all).reflow();
    }

    final len = add.length;
    final src = source?.length;
    if (src != null && src != len) {
      mod = source!;
      if (len != 0) {
        filter(PulseVisitType.mod, _filter(this, PulseVisitType.add));
      }
    }
    return this;
  }

  Pulse<D> modify() {
    fields = true;
    return this;
  }

  bool get modifiedAny => mod.isNotEmpty && fields;

  bool modified([bool noMod = false]) {
    if (!noMod && mod.isEmpty) {
      return false;
    }
    return fields;
  }

  Pulse<D> filter(int flags, TupleFilter<D> filter) {
    if (mask_util.contain(flags, PulseVisitType.add)) {
      addF = _addFilter(addF, filter);
    }
    if (mask_util.contain(flags, PulseVisitType.rem)) {
      remF = _addFilter(remF, filter);
    }
    if (mask_util.contain(flags, PulseVisitType.mod)) {
      modF = _addFilter(modF, filter);
    }
    if (mask_util.contain(flags, PulseVisitType.source)) {
      sourceF = _addFilter(sourceF, filter);
    }
    return this;
  }

  Pulse<D> materialize([int flags = PulseVisitType.all]) {
    if (mask_util.contain(flags, PulseVisitType.add) && addF != null) {
      add = _materialize(add, addF!);
      addF = null;
    }
    if (mask_util.contain(flags, PulseVisitType.rem) && remF != null) {
      rem = _materialize(rem, remF!);
      remF = null;
    }
    if (mask_util.contain(flags, PulseVisitType.mod) && modF != null) {
      mod = _materialize(mod, modF!);
      modF = null;
    }
    if (mask_util.contain(flags, PulseVisitType.source) && sourceF != null) {
      if (source != null) {
        source = _materialize(source!, sourceF!);
      }
      sourceF = null;
    }
    return this;
  }

  Pulse<D> visit(int flags, TupleVisitor<D> visitor) {
    if (mask_util.contain(flags, PulseVisitType.source) && source != null) {
      _visitTupleList(source!, sourceF, visitor);
      return this;
    }

    if (mask_util.contain(flags, PulseVisitType.add)) {
      _visitTupleList(add, addF, visitor);
    }
    if (mask_util.contain(flags, PulseVisitType.rem)) {
      _visitTupleList(rem, remF, visitor);
    }
    if (mask_util.contain(flags, PulseVisitType.mod)) {
      _visitTupleList(mod, modF, visitor);
    }

    if (mask_util.contain(flags, PulseVisitType.reflow) && source != null) {
      final sum = add.length + mod.length;
      if (sum == source!.length) {
        
      } else if (sum != 0) {
        _visitTupleList(source!, _filter(this, PulseVisitType.addMod), visitor);
      } else {
        _visitTupleList(source!, sourceF, visitor);
      }
    }

    return this;
  }
}
