import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/interaction/signal.dart';
import 'package:graphic/src/parse/parse.dart';

/// The signal that may be emitted when data changes.
///
/// Whether to emit a change data signal is also affected by [Chart.changeData].
///
/// See also:
///
/// - [Chart.changeData], The behavior of whether to emit this signal when data changes.
class ChangeDataSignal<D> extends Signal {
  /// Creates a change data signal.
  ChangeDataSignal(this.data);

  @override
  SignalType get type => SignalType.changeData;

  /// The new data.
  final List<D> data;
}

class DataOp<D> extends Value<List<D>> {
  DataOp(List<D> value) : super(value);
}

void parseData<D>(
  Chart<D> spec,
  View<D> view,
  Scope<D> scope,
) {
  scope.data = view.add(DataOp(spec.data));

  view.listen<ChangeDataSignal<D>, List<D>>(
    view.dataSouce,
    scope.data,
    (signal) => signal.data,
  );
}
