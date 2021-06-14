import 'dart:ui';

import 'package:graphic/src/control/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'single_variable.dart';

class ColorAttr<D> extends SingleVariableAttr<Color> {
  ColorAttr({
    Color? value,
    String? variable,
    List<Color>? values,
    List<Color>? range,
    Signal<Color>? signal,
    Color Function(Tuple)? encode,
  }) 
    : assert(isSingle([value, variable, signal, encode])),
      super(
        value: value,
        variable: variable,
        values: values,
        range: range,
        signal: signal,
        encode: encode,
      );
}
