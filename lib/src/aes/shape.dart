import 'package:graphic/src/interaction/select/select.dart';
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
    Map<String, Map<bool, SelectUpdate<Shape>>>? onSelect,
  })
    : assert(isSingle([value, variable, encode])),
      super(
        value: value,
        variable: variable,
        values: values,
        encode: encode,
        onSelect: onSelect,
      );
}
