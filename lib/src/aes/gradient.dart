import 'package:flutter/painting.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

class GradientAttr extends ChannelAttr<Gradient> {
  GradientAttr({
    Gradient? value,
    String? variable,
    List<Gradient>? values,  // Only descrete.
    Gradient Function(Original)? encode,
    Map<String, Map<bool, SelectUpdate<Gradient>>>? onSelect,
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
