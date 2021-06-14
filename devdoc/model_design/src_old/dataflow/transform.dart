import 'operator.dart';
import 'parameters.dart';
import 'pulse.dart';

abstract class Transform<V, D> extends Operator<V, D> {
  Transform(
    [V? init,
    Parameters? parameters,]
  ) : super(init, null, parameters);

  @override
  Pulse<D>? run(Pulse<D> pulse) {
    if (pulse.clock < clock) {
      return Pulse<D>.stopPropagation();
    }

    Pulse<D>? rv;
    if (skip) {
      skip = false;
    } else {
      rv = evaluate(pulse);
    }
    rv = rv ?? pulse;

    if (rv.then != null) {
      rv = rv.then!((p) { this.pulse = p; });
    } else if (!rv.stopPropagation) {
      this.pulse = rv;
    }

    return rv;
  }

  @override
  Pulse<D>? evaluate(Pulse<D> pulse) {
    final parameters = marshall(pulse.clock);
    final rst = transform(parameters, pulse);
    parameters.clear();
    return rst;
  }

  Pulse<D>? transform(Parameters parameters, Pulse<D> pulse);
}
