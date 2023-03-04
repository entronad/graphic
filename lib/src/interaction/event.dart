import 'package:graphic/src/chart/size.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/data/data_set.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/interaction/gesture.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/util/assert.dart';

/// Types of [Event]s.
enum EventType {
  /// The type of [GestureEvent].
  gesture,

  /// The type of [ResizeEvent].
  resize,

  /// The type of [ChangeDataEvent].
  changeData,
}

/// The base class of events.
///
/// An event is emitted when users or external changes interact with the chart.
/// They may trigger selections if defined.
///
/// They usually carry properties of information about the interaction.
///
/// See also:
///
/// - [EventUpdater], updates a value when a event occurs.
/// - [Selection], to define a selection.
abstract class Event {
  /// type of the event.
  EventType get type;
}

/// Updates a value when a event occurs.
///
/// The [initialValue] is the value set in the specification. The [preValue] is
/// previous value before this update.
///
/// Make sure the return value is a different instance from initialValue or preValue.
typedef EventUpdater<V> = V Function(
    V initialValue, V preValue, Event event);

/// The event value operator.
class EventOp<S extends Event> extends Value<S?> {
  @override
  bool get consume => true;
}

/// The event reduces all types events.
class EventReducerOp<D> extends Operator<Event?> {
  EventReducerOp(Map<String, dynamic> params) : super(params);

  @override
  bool get runInit => false;

  @override
  Event? evaluate() {
    final gesture = params['gesture'] as GestureEvent?;
    final resize = params['resize'] as ResizeEvent?;
    final changeData = params['changeData'] as ChangeDataEvent<D>?;

    assert(isSingle([gesture, resize, changeData]));
    return [gesture, resize, changeData]
        .singleWhere((mark) => mark != null);
  }
}

/// The operator to update a value by a event.
///
/// The operator value is the updated value.
class EventUpdateOp<V> extends Operator<V> {
  EventUpdateOp(Map<String, dynamic> params) : super(params);

  @override
  V evaluate() {
    final update = params['update'] as EventUpdater<V>;
    final initialValue = params['initialValue'] as V;
    final event = params['event'] as Event?;

    if (value == null || event == null) {
      // When the value has not been initialized or the evaluation is triggered
      // by initialValue change.

      return initialValue;
    }

    return update(initialValue, value as V, event);
  }
}
