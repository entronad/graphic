import 'package:graphic/src/control/signal.dart';
import 'package:graphic/src/shape/base.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'single_variable.dart';

class ShapeAttr extends SingleVariableAttr<Shape> {
  ShapeAttr({
    Shape? value,
    String? variable,
    List<Shape>? values,  // Only descrete.
    Signal<Shape>? signal,
    Shape Function(Tuple)? encode,
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
