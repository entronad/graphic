import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

class ShapeAttr<S extends Shape> extends ChannelAttr<S> {
  ShapeAttr({
    S? value,
    String? variable,
    List<S>? values,  // Only descrete.
    S Function(Original)? encode,
    Map<String, Map<bool, SelectUpdate<S>>>? onSelect,
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
