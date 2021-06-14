import 'package:graphic/src/util/mask.dart' as mask_util;

import 'pulse.dart';
import 'dataflow.dart';

class MultiPulse<D> extends Pulse<D> {
  MultiPulse(
    Dataflow<D> dataflow,
    int clock,
    this.pulses,
    String? encode,
  ) : super(dataflow, clock, encode) {
    var c = 0;

    for (var pulse in pulses) {
      if (pulse.clock != clock) {
        continue;
      }

      if (pulse.fields) {
        fields = true;
      }

      if (pulse.changed(PulseVisitType.add)) {
        c |= PulseVisitType.add;
      }
      if (pulse.changed(PulseVisitType.rem)) {
        c |= PulseVisitType.rem;
      }
      if (pulse.changed(PulseVisitType.mod)) {
        c |= PulseVisitType.mod;
      }
    }

    changes = c;
  }

  final List<Pulse<D>> pulses;
  int changes = 0;

  @override
  Pulse<D> fork([int flags = 0]) {
    final p = Pulse(dataflow).init(this, flags & PulseVisitType.noFields);
    if (flags != 0) {
      if (mask_util.contain(flags, PulseVisitType.add)) {
        visit(PulseVisitType.add, (t) { add.add(t); });
      }
      if (mask_util.contain(flags, PulseVisitType.rem)) {
        visit(PulseVisitType.rem, (t) { rem.add(t); });
      }
      if (mask_util.contain(flags, PulseVisitType.mod)) {
        visit(PulseVisitType.mod, (t) { mod.add(t); });
      }
    }
    return p;
  }

  @override
  bool changed([int? flags]) =>
    mask_util.contain(changes, flags ?? 0);
  
  @override
  bool get modifiedAny {
    throw UnimplementedError('MultiPulse does not support modifiedAny.');
  }

  @override
  bool modified([bool noMod = false]) {
    assert(noMod == false);

    if (!fields || !mask_util.contain(changes, PulseVisitType.mod)) {
      return false;
    }
    return fields;
  }

  @override
  Pulse<D> filter(int flags, filter) {
    throw UnimplementedError('MultiPulse does not support filter.');
  }

  @override
  Pulse<D> materialize([int flags = PulseVisitType.all]) {
    throw UnimplementedError('MultiPulse does not support materiialize.');
  }

  @override
    Pulse<D> visit(int flags, visitor) {
      if (mask_util.contain(flags, PulseVisitType.source)) {
        for (var pulse in pulses) {
          pulse.visit(flags, visitor);
        }
      } else {
        for (var pulse in pulses) {
          if (pulse.clock == clock) {
            pulse.visit(flags, visitor);
          }
        }
      }

      return this;
    }
}
