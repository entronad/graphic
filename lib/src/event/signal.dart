import 'package:graphic/src/dataflow/operator.dart';

import 'event.dart';

/// Make sure the return value is different instance from initialValue or preValue.
typedef SignalUpdate<V, E extends Event> = V Function(V initialValue, V preValue, E event);

typedef Signal<V> = Map<EventType, SignalUpdate<V, Event>>;

class SignalOp<V> extends Operator<V> {
  SignalOp(Map<String, dynamic> params) : super(params);

  @override
  V evaluate() {
    final signal = params['signal'] as Signal<V>;
    final initialValue = params['initialValue'] as V;
    final event = params['event'] as Event?;

    // Value init or change.
    if (value == null || event == null) {
      return initialValue;
    }

    final update = signal[event.type];
    if (update == null) {
      return initialValue;
    }

    return update(initialValue, value!, event);
  }
}
