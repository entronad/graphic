import 'package:graphic/graphic.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';

import 'event.dart';

/// Make sure the return value is different instance from initialValue or preValue.
typedef SignalUpdate<V, E extends Event> = V Function(V initialValue, V preValue, E event);

typedef Signal<V> = Map<EventType, SignalUpdate<V, Event>>;

class SignalOp extends Value<Event?> {
  @override
  bool get consume => true;
}

class SignalUpdateOp<V> extends Operator<V> {
  SignalUpdateOp(Map<String, dynamic> params) : super(params);

  @override
  V evaluate() {
    final spec = params['spec'] as Signal<V>;
    final initialValue = params['initialValue'] as V;
    final signal = params['signal'] as Event?;

    // Value init or change.
    if (value == null || signal == null) {
      return initialValue;
    }

    final update = spec[signal.type];
    if (update == null) {
      return initialValue;
    }

    return update(initialValue, value!, signal);
  }
}

void parseSignal<D>(
  Spec<D> spec,
  View<D> view,
  Scope<D> scope,
) {
  scope.signal = view.add(SignalOp());

  view
    ..listen<Event, Event?>(
      view.gestureSource,
      scope.signal,
      (event) => event,
    )
    ..listen<Event, Event?>(
      view.sizeSouce,
      scope.signal,
      (event) => event,
    )
    ..listen<Event, Event?>(
      view.dataSouce,
      scope.signal,
      (event) => event,
    );
}
