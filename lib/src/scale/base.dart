/// [V]: Type of input variable value.
/// [SV]: Type of scaled value result,
///     [int] for discrete and
///     [double] for continuous.
abstract class Scale<V, SV extends num> {
  Scale({
    this.formatter,
  });

  final String Function(V)? formatter;

  @override
  bool operator ==(Object other) =>
    other is Scale<V, SV>;
    // formatter: Function
}
