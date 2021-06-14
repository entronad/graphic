import 'base.dart';

abstract class DiscreteScale<V> extends Scale<V, int> {
  DiscreteScale({
    this.values,

    String Function(V)? formatter,
  }) : super(
    formatter: formatter,
  );

  final List<V>? values;
}
