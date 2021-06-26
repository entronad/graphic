import 'base.dart';
import 'op_params.dart';
import '../pulse/pulse.dart';

class Updator<V> extends Operator<V> {
  Updator(
    V value,
    [Map<String, dynamic>? params,
    V Function(OpParams params, Pulse pulse)? update,
    bool react = true]
  )
    : _update = update,
      super(value, params, react);

  V Function(OpParams params, Pulse pulse)? _update;

  @override
  OpParams marshall([int clock = -1]) {
    final rst = super.marshall(clock);

    if (initOnly) {
      _update = null;
    }

    return rst;
  }

  @override
  Pulse? evaluete(Pulse pulse) {
    if (_update != null) {
      final params = marshall(pulse.clock);
      final v = _update!(params, pulse);
      params.clear();
      if (v == value) {
        if (!modified) {
          // If value and operator are both same, stop propagation.
          this.pulse = null;
          return null;
        }
        // If operator changed but value is same, pass through. 
        this.pulse = pulse;
        return pulse;
      }
      // Update and propagate.
      value = v;
      this.pulse = pulse;
      return pulse;
    } else {
      // Pass through.
      this.pulse = pulse;
      return pulse;
    }
  }
}
