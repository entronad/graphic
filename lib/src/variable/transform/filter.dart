import 'package:graphic/src/dataflow/tuple.dart';

import 'transform.dart';

class Filter extends Transform {
  Filter({
    required this.filter,
  });

  final bool Function(Original) filter;

  @override
  bool operator ==(Object other) =>
    other is Filter &&
    super == other;
    // filter is Function.
}

class FilterOp extends TransformOp {
  FilterOp(Map<String, dynamic> params) : super(params);

  @override
  List<Original> evaluate() {
    final originals = params['originals'] as List<Original>;
    final filter = params['filter'] as bool Function(Original);

    return originals.where((original) => filter(original)).toList();
  }
}
