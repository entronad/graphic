import 'package:graphic/src/event/selection/selection.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

class ShapeAttr extends ChannelAttr<Shape> {
  ShapeAttr({
    Shape? value,
    String? variable,
    List<Shape>? values,  // Only descrete.
    Shape Function(Original)? encode,
    Map<String, Map<bool, SelectionUpdate<Shape>>>? onSelection,
  })
    : assert(isSingle([value, variable, encode])),
      super(
        value: value,
        variable: variable,
        values: values,
        encode: encode,
        onSelection: onSelection,
      );
}
