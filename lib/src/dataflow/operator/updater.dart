import 'operator.dart';
import 'op_params.dart';
import '../pulse/pulse.dart';

/// Updator will not handle the pulse.
/// It only returns the original pulse or null.
/// It focuses on value for param of other operators.
class Updater<V> extends Operator<V> {
  Updater(
    V value,
    [Map<String, dynamic>? params,
    V Function(OpParams params, Pulse pulse)? update,
    bool reactive = true]
  )
    : _update = update,
      super(value, params, reactive);

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
      if (v != value) {
        value = v;
      }
      if (!modified) {
        // If value and operator are both same, stop propagation.
        return null;
      }
    }
    return pulse;
  }
}
