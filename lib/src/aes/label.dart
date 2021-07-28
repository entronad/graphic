import 'package:graphic/src/common/styles.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'aes.dart';

class Label {
  Label(this.text, this.style);

  final String text;

  final LableSyle style;

  @override
  bool operator ==(Object other) =>
    other is Label &&
    text == other.text &&
    style == other.style;
}

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
