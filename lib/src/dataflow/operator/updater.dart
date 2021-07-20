import 'package:meta/meta.dart';

import 'operator.dart';
import '../pulse/pulse.dart';

/// Updator will not handle the pulse.
/// It only returns the original pulse or null.
/// It focuses on value for param of other operators.
abstract class Updater<V> extends Operator<V> {
  Updater(
    [Map<String, dynamic>? params,
    V? value,
    bool reactive = true]
  ) : super(params, value, reactive);

  @override
  Pulse? evaluete(Pulse pulse) {
    if (!initOnly) {
      marshall(pulse.clock);
      final v = update(pulse);
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

  @protected
  V update(Pulse pulse);
}
