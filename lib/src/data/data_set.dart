import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/interaction/event.dart';

/// The event that may be emitted when data changes.
///
/// Whether to emit a change data event is also affected by [Chart.changeData].
///
/// See also:
///
/// - [Chart.changeData], The behavior of whether to emit this event when data changes.
class ChangeDataEvent<D> extends Event {
  /// Creates a change data event.
  ChangeDataEvent(this.data);

  @override
  EventType get type => EventType.changeData;

  /// The new data.
  final List<D> data;
}

/// The input data operator.
class DataOp<D> extends Operator<List<D>> {
  DataOp(
    Map<String, dynamic> params,
    List<D> value,
  ) : super(params, value);

  @override
  bool get runInit => false;

  @override
  List<D> evaluate() {
    final event = params['event'] as ChangeDataEvent<D>;
    return event.data;
  }

  // In case the change data event is triggerd by modifying the same data list
  // instance and force Chart.changeData to true, the data operator value is always
  // regarded different when updated.
  @override
  bool equalValue(List<D> a, List<D> b) => false;
}
