import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/parse/parse.dart';

/// Types of [Signal]s.
enum SignalType {
  /// The type of [GestureSignal].
  gesture,

  /// The type of [ResizeSignal].
  resize,

  /// The type of [ChangeDataSignal].
  changeData,
}

/// The base class for signals.
/// 
/// An signal is emitted when users or external changes interact with the chart.
/// They may trigger selections if defined.
/// 
/// They usually carry properties of information about the interaction.
/// 
/// See also:
/// 
/// - [SignalUpdate], updates a value when a signal occurs.
/// - [Selection], to define a selection.
abstract class Signal {
  /// type of the signal.
  SignalType get type;
}

/// Updates a value when a signal occurs.
/// 
/// The [initialValue] is the value set in the specification. The [preValue] is
/// previous value before this update.
/// 
/// Make sure the return value is a different instance from initialValue or preValue.
typedef SignalUpdate<V> = V Function(V initialValue, V preValue, Signal signal);

typedef SignalListener<S extends Signal> = void Function(S);

class SignalSource<S extends Signal> {
  final _listeners = <SignalListener<S>?>[];

  int on(SignalListener<S> listener) {
    _listeners.add(listener);
    return _listeners.length - 1;
  }

  void off(int id) =>
    _listeners[id] = null;

  void clear() =>
    _listeners.clear();

  Future<void> emit (S signal) async {
    for (var listener in _listeners) {
      if (listener != null) {
        listener(signal);
      }
    }
  }
}

class SignalOp extends Value<Signal?> {
  @override
  bool get consume => true;
}

class SignalUpdateOp<V> extends Operator<V> {
  SignalUpdateOp(Map<String, dynamic> params) : super(params);

  @override
  V evaluate() {
    final update = params['update'] as SignalUpdate<V>;
    final initialValue = params['initialValue'] as V;
    final signal = params['signal'] as Signal?;

    // Value init or change.
    if (value == null || signal == null) {
      return initialValue;
    }

    return update(initialValue, value!, signal);
  }
}

void parseSignal<D>(
  Chart<D> spec,
  View<D> view,
  Scope<D> scope,
) {
  scope.signal = view.add(SignalOp());

  view
    ..listen<Signal, Signal?>(
      view.gestureSource,
      scope.signal,
      (signal) => signal,
    )
    ..listen<Signal, Signal?>(
      view.sizeSouce,
      scope.signal,
      (signal) => signal,
    )
    ..listen<Signal, Signal?>(
      view.dataSouce,
      scope.signal,
      (signal) => signal,
    );
}
