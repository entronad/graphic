import 'package:flutter/painting.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

/// The specification of a gradient attribute.
/// 
/// The definition of the [Gradient] value is relative to measurement of the element
/// item.
class GradientAttr extends ChannelAttr<Gradient> {
  /// Creates a gradient attribute.
  GradientAttr({
    Gradient? value,
    String? variable,
    List<Gradient>? values,
    List<double>? stops,
    Gradient Function(Tuple)? encode,
    Map<String, Map<bool, SelectionUpdate<Gradient>>>? onSelection,
  })
    : assert(isSingle([value, variable, encode])),
      super(
        value: value,
        variable: variable,
        values: values,
        stops: stops,
        encode: encode,
        onSelection: onSelection,
      );
}

class ContinuousGradientConv extends ContinuousChannelConv<Gradient> {
  ContinuousGradientConv(List<Gradient> values, List<double> stops)
    : super(values, stops);

  @override
  Gradient lerp(Gradient a, Gradient b, double t) =>
    Gradient.lerp(a, b, t)!;
}
