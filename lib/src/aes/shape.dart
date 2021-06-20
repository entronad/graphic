import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/shape/base.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'single_variable.dart';

class ShapeAttr extends SingleVariableAttr<Shape> {
  ShapeAttr({
    Shape? value,
    String? variable,
    List<Shape>? values,  // Only descrete.
    Shape Function(Tuple)? encode,
    Signal<Shape>? signal,
    Map<Select, SelectUpdate<Shape>>? select,
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
