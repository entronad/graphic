import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

/// The specification of a size attribute.
class SizeAttr extends ChannelAttr<double> {
  /// Creates a size attribute.
  SizeAttr({
    double? value,
    String? variable,
    List<double>? values,
    List<double>? stops,
    double Function(Tuple)? encoder,
    Map<String, Map<bool, SelectionUpdater<double>>>? onSelection,
  })  : assert(isSingle([value, variable, encoder])),
        super(
          value: value,
          variable: variable,
          values: values,
          stops: stops,
          encoder: encoder,
          onSelection: onSelection,
        );
}

/// The continuous size attribute converter.
class ContinuousSizeConv extends ContinuousChannelConv<double> {
  ContinuousSizeConv(List<double> values, List<double> stops)
      : super(values, stops);

  @override
  double lerp(double a, double b, double t) => (b - a) * t + a;
}
