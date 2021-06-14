import 'package:flutter/painting.dart';

import 'package:graphic/src/control/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'single_variable.dart';

class GradientAttr<D> extends SingleVariableAttr<Gradient> {
  GradientAttr({
    Gradient? value,
    String? variable,
    List<Gradient>? values,  // Only descrete.
    Signal<Gradient>? signal,
    Gradient Function(Tuple)? encode,
  })
    : assert(isSingle([value, variable, signal, encode])),
      super(
        value: value,
        variable: variable,
        values: values,
        signal: signal,
        encode: encode,
      );
}
