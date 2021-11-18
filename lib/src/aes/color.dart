import 'dart:ui';

import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

/// The specification of a color attribute.
class ColorAttr extends ChannelAttr<Color> {
  /// Creates a color attribute.
  ColorAttr({
    Color? value,
    String? variable,
    List<Color>? values,
    List<double>? stops,
    Color Function(Tuple)? encoder,
    Map<String, Map<bool, SelectionUpdater<Color>>>? onSelection,
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

/// The continuous color attribute converter.
class ContinuousColorConv extends ContinuousChannelConv<Color> {
  ContinuousColorConv(List<Color> values, List<double> stops)
      : super(values, stops);

  @override
  Color lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;
}
