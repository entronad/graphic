import 'package:collection/collection.dart';

import 'scale.dart';

abstract class DiscreteScale<V> extends Scale<V, int> {
  DiscreteScale({
    this.values,
    this.align,

    String Function(V)? formatter,
  }) : super(
    formatter: formatter,
  );

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
