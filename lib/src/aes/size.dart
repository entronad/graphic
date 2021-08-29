import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

class SizeAttr extends ChannelAttr<double> {
  SizeAttr({
    double? value,
    String? variable,
    List<double>? values,
    List<double>? stops,
    double Function(Original)? encode,
    Map<String, Map<bool, SelectUpdate<double>>>? onSelect,
  })
    : assert(isSingle([value, variable, encode])),
      super(
        value: value,
        variable: variable,
        values: values,
        stops: stops,
        encode: encode,
        onSelect: onSelect,
      );
}

class ContinuousSizeConv extends ContinuousChannelConv<double> {
  ContinuousSizeConv(List<double> values, List<double> stops)
    : super(values, stops);

  @override
  double lerp(double a, double b, double t) =>
    (b - a) * t + a;
}
