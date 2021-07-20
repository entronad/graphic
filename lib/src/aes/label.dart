import 'package:flutter/painting.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'aes.dart';

class LabelAttr extends Attr<TextSpan> {
  LabelAttr({
    required TextSpan Function(Tuple) encode,
    Signal<TextSpan>? signal,
    Map<Select, SelectUpdate<TextSpan>>? select,
  }) : super(
    encode: encode,
    signal: signal,
    select: select,
  );

  // TODO: label position: bbox? point?
}
