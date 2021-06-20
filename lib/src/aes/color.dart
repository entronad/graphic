import 'dart:ui';

import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'single_variable.dart';

class ColorAttr<D> extends SingleVariableAttr<Color> {
  ColorAttr({
    Color? value,
    String? variable,
    List<Color>? values,
    List<Color>? range,
    Color Function(Tuple)? encode,
    Signal<Color>? signal,
    Map<Select, SelectUpdate<Color>>? select,
  }) 
    : assert(isSingle([value, variable, encode])),
      super(
        value: value,
        variable: variable,
        values: values,
        range: range,
        encode: encode,
        signal: signal,
        select: select,
      );
}
