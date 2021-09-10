import 'package:graphic/src/dataflow/tuple.dart';

import 'transform.dart';

class Sort extends Transform {
  Sort({
    required this.compare,
  });

  final Comparator<Original> compare;

  @override
  bool operator ==(Object other) =>
    other is Sort &&
    super == other;
    // compare is Function.
}

class SortOp extends TransformOp {
  SortOp(Map<String, dynamic> params) : super(params);

  @override
  List<Original> evaluate() {
    final originals = params['originals'] as List<Original>;
    final compare = params['compare'] as Comparator<Original>;

    return originals..sort(compare);
  }
}
