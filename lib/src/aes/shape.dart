import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

class ShapeAttr extends ChannelAttr<Shape> {
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
