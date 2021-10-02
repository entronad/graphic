import 'package:flutter/painting.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

class GradientAttr extends ChannelAttr<Gradient> {
  GradientAttr({
    Gradient? value,
    String? variable,
    List<Gradient>? values,
    List<double>? stops,
    Gradient Function(Original)? encode,
    Map<String, Map<bool, SelectUpdate<Gradient>>>? onSelect,
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

class ContinuousGradientConv extends ContinuousChannelConv<Gradient> {
  ContinuousGradientConv(List<Gradient> values, List<double> stops)
    : super(values, stops);

  @override
  Gradient lerp(Gradient a, Gradient b, double t) =>
    Gradient.lerp(a, b, t)!;
}
