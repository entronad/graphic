import 'base.dart';

import 'package:graphic/src/dataflow/tuple.dart';

class LabelAttr<D> extends Attr<String> {
  LabelAttr({
    required String Function(Tuple) encode,
  }) : super(
    encode: encode,
  );
}
