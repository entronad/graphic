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

  /// How the position will align in the band.
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
  DiscreteScaleConv(this.values, this.align);

  List<V>? values;

  double? align;

  double? band;

  @override
  void complete(List<Tuple> tuples, String field) {
    if (values == null) {
      final candidates = <V>{};
      for (var tuple in tuples) {
        candidates.add(tuple[field]);
      }
      values = candidates.toList();
    }

    align = align ?? 0.5;
    band = 1 / values!.length;
  }

  @override
  int convert(V input) {
    assert(values!.contains(input));
    return values!.indexOf(input);
  }

  @override
  V invert(int output) {
    assert(output >= 0 && output < values!.length);
    return values![output];
  }

  @override
  double normalize(int scaledValue) =>
    (scaledValue + align!) * band!;

  @override
  int denormalize(double normalValue) =>
    (normalValue / band! - align!).round();
  
  @override
  V get zero => values!.first;
}
