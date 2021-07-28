import 'dart:ui';

import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

class ColorAttr extends ChannelAttr<Color> {
  ColorAttr({
    Color? value,
    String? variable,
    List<Color>? values,
    List<double>? stops,
    Color Function(Tuple)? encode,
    Signal<Color>? signal,
    Map<Select, SelectUpdate<Color>>? select,
  }) 
    : assert(isSingle([value, variable, encode])),
      super(
        value: value,
        variable: variable,
        values: values,
        stops: stops,
        encode: encode,
        signal: signal,
        select: select,
      );
}

class ContinuousColorConv extends ContinuousChannelConv<Color> {
  ContinuousColorConv(List<Color> values, List<double> stops)
    : super(values, stops);

  @override
  Color lerp(Color a, Color b, double t) =>
    Color.lerp(a, b, t)!;
}
