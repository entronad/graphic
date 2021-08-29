import 'package:graphic/src/common/label.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'aes.dart';

class LabelAttr extends Attr<Label> {
  LabelAttr({
    required Label Function(Original) encode,
    Map<String, Map<bool, SelectUpdate<Label>>>? onSelect,
  }) : super(
    encode: encode,
    onSelect: onSelect,
  );
}
