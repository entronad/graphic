import 'package:graphic/src/util/mask.dart' as mask_util;

import 'pulse.dart';
import '../dataflow.dart';
import '../tuple.dart';

/// Created with a list of pulses.
/// Return a sigle pulse when forked.
class MultiPulse extends Pulse {
  MultiPulse(
    Dataflow dataflow,
    int clock,
    this.pulses,
  ) : super(
    dataflow,
    clock,
  ) {
    for (var pulse in pulses) {
      if (pulse.clock != clock) {
        continue;
      }

      modFields.addAll(pulse.modFields);

      if (pulse.changed(PulseFlags.add)) {
        changedFlags |= PulseFlags.add;
      }
      if (pulse.changed(PulseFlags.rem)) {
        changedFlags |= PulseFlags.rem;
      }
      if (pulse.changed(PulseFlags.mod)) {
        changedFlags |= PulseFlags.mod;
      }
    }
  }

  final List<Pulse> pulses;

  int changedFlags = 0;

  @override
  Pulse fork([int flags = PulseFlags.source | PulseFlags.modFields]) {
    final pulse = Pulse.from(this, flags & PulseFlags.modFields);  // Only check modFields flag.

    if (mask_util.contain(flags, PulseFlags.add)) {
      visit(PulseFlags.add, (t) { pulse.add.add(t); });
    }
    if (mask_util.contain(flags, PulseFlags.rem)) {
      visit(PulseFlags.rem, (t) { pulse.rem.add(t); });
    }
    if (mask_util.contain(flags, PulseFlags.mod)) {
      visit(PulseFlags.mod, (t) { pulse.mod.add(t); });
    }

    return pulse;
  }

  @override
  bool changed([int flags = PulseFlags.all]) =>
    mask_util.contain(changedFlags, flags);

  @override
  bool modified([Set<String>? fields, bool noMod = false]) {
    if (!(modFields.isNotEmpty && mask_util.contain(changedFlags, PulseFlags.mod))) {
      return false;
    }
    assert(fields != null);
    return fields!.any((field) => modFields.contains(field));
  }

  @override
  Pulse addFilter(int flags, TupleFilter filter) =>
    throw UnimplementedError('MultiPulse does not support addFilter.');

  @override
  Pulse materialize([int flags = PulseFlags.all]) =>
    throw UnimplementedError('MultiPulse does not support materiialize.');
  
  @override
  Pulse visit(int flags, TupleVisitor visitor) {
    if (mask_util.contain(flags, PulseFlags.source)) {
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
