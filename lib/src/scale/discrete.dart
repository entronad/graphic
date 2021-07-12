import 'package:collection/collection.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'scale.dart';

abstract class DiscreteScale<V> extends Scale<V, int> {
  DiscreteScale({
    this.values,
    this.align,

    String Function(V)? formatter,
  }) : super(
    formatter: formatter,
  );

  /// List is to emphasize the order. It's better to be distinct.
  final List<V>? values;

  /// How the postion will align in the band.
  /// Default is 0.5 in [0, 1].
  final double? align;

  @override
  bool operator ==(Object other) =>
    other is DiscreteScale<V> &&
    super == other &&
    DeepCollectionEquality().equals(values, other.values) &&
    align == other.align;
}

abstract class DiscreteScaleConv<V> extends ScaleConv<V, int> {
  DiscreteScaleConv(this.values);

  List<V>? values;

  @override
  void complete(List<Tuple> tuples, String field) {
    if (values == null) {
      final candidates = <V>{};
      for (var tuple in tuples) {
        candidates.add(tuple[field]);
      }
      values = candidates.toList();
    }
  }
}
