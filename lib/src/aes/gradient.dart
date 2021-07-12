import 'package:flutter/painting.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'single_variable.dart';

class GradientAttr extends SingleVariableAttr<Gradient> {
  GradientAttr({
    Gradient? value,
    String? variable,
    List<Gradient>? values,  // Only descrete.
    Gradient Function(Tuple)? encode,
    Signal<Gradient>? signal,
    Map<Select, SelectUpdate<Gradient>>? select,
  })
    : assert(isSingle([value, variable, encode])),
      super(
        value: value,
        variable: variable,
        values: values,
        encode: encode,
        signal: signal,
        select: select,
      );
}
