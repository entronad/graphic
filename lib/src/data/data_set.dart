import 'package:graphic/src/chart/chart.dart';
import 'package:graphic/src/common/operators/value.dart';
import 'package:graphic/src/interaction/signal.dart';

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

/// The input data value operator.
class DataOp<D> extends Value<List<D>> {
  DataOp(List<D> value) : super(value);
}
