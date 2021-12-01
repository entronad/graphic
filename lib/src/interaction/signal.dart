import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/interaction/selection/selection.dart';

/// Types of [Signal]s.
enum SignalType {
  /// The type of [GestureSignal].
  gesture,

  /// The type of [ResizeSignal].
  resize,

  /// The type of [ChangeDataSignal].
  changeData,
}

/// The base class of signals.
///
/// An signal is emitted when users or external changes interact with the chart.
/// They may trigger selections if defined.
///
/// They usually carry properties of information about the interaction.
///
/// See also:
///
/// - [SignalUpdater], updates a value when a signal occurs.
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
typedef SignalUpdater<V> = V Function(
    V initialValue, V preValue, Signal signal);

/// The souce to generate signals.
class SignalSource<S extends Signal> {
  /// The registered listeners.
  final _listeners = <void Function(S)?>[];

  /// Registers a listener, and returns id of the listener.
  int on(void Function(S) listener) {
    _listeners.add(listener);
    return _listeners.length - 1;
  }

  /// Releases a listener by id.
  void off(int id) => _listeners[id] = null;

  /// Releases all listeners.
  void clear() => _listeners.clear();

  /// Emit a signal and broadcast it to all listeners.
  Future<void> emit(S signal) async {
    for (var listener in _listeners) {
      if (listener != null) {
        listener(signal);
      }
    }
  }
}

/// The signal value operator.
class SignalOp extends Value<Signal?> {
  @override
  bool get consume => true;
}

/// The operator to update a value by a signal.
///
/// The operator value is the updated value.
class SignalUpdateOp<V> extends Operator<V> {
  SignalUpdateOp(Map<String, dynamic> params) : super(params);

  @override
  V evaluate() {
    final update = params['update'] as SignalUpdater<V>;
    final initialValue = params['initialValue'] as V;
    final signal = params['signal'] as Signal?;

    if (value == null || signal == null) {
      // When the value has not been initialized or the evaluation is triggered
      // by initialValue change.

      return initialValue;
    }

    return update(initialValue, value!, signal);
  }
}
