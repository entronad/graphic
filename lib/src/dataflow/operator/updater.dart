import 'operator.dart';
import 'op_params.dart';
import '../pulse/pulse.dart';

/// Updator will not handle the pulse.
/// It only returns the original pulse or null.
/// It focuses on value for param of other operators.
abstract class Updater<V> extends Operator<V> {
  Updater(
    V value,
    [Map<String, dynamic>? params,
    bool reactive = true]
  ) : super(value, params, reactive);

  V update(OpParams params, Pulse pulse);

  @override
  Pulse? evaluete(Pulse pulse) {
    if (!initOnly) {
      final params = marshall(pulse.clock);
      final v = update(params, pulse);
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
