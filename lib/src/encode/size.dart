import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

/// The specification of a size encode.
class SizeEncode extends ChannelEncode<double> {
  /// Creates a size encode.
  SizeEncode({
    double? value,
    String? variable,
    List<double>? values,
    List<double>? stops,
    double Function(Tuple)? encoder,
    Map<String, Map<bool, SelectionUpdater<double>>>? updaters,
  })  : assert(isSingle([value, variable, encoder])),
        super(
          value: value,
          variable: variable,
          values: values,
          stops: stops,
          encoder: encoder,
          updaters: updaters,
        );
}

/// The continuous size encode converter.
class ContinuousSizeConv extends ContinuousChannelConv<double> {
  ContinuousSizeConv(List<double> values, List<double> stops)
      : super(values, stops);

  @override
  double lerp(double a, double b, double t) => (b - a) * t + a;
}
