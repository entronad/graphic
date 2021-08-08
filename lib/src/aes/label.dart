import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'aes.dart';

class LabelAttr extends Attr<Label> {
  LabelAttr({
    required Label Function(Tuple) encode,
    Signal<Label>? signal,
    Map<Select, SelectUpdate<Label>>? select,
  }) : super(
    encode: encode,
    signal: signal,
    select: select,
  );
}
