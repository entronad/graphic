import 'dart:ui';

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

/// The specification of a color encode.
class ColorEncode extends ChannelEncode<Color> {
  /// Creates a color encode.
  ColorEncode({
    Color? value,
    String? variable,
    List<Color>? values,
    List<double>? stops,
    Color Function(Tuple)? encoder,
    Map<String, Map<bool, SelectionUpdater<Color>>>? updaters,
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

/// The continuous color encode converter.
class ContinuousColorConv extends ContinuousChannelConv<Color> {
  ContinuousColorConv(List<Color> values, List<double> stops)
      : super(values, stops);

  @override
  Color lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;
}
