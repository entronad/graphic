import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/event/selection/selection.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'aes.dart';

class LabelAttr extends Attr<Label> {
  LabelAttr({
    required Label Function(Original) encode,
    Map<String, Map<bool, SelectionUpdate<Label>>>? onSelection,
  }) : super(
    encode: encode,
    onSelection: onSelection,
  );
}
