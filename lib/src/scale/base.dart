import 'package:graphic/src/parse/spec.dart';

/// [V]: Type of input variable value.
/// [SV]: Type of scaled value result,
///     [int] for discrete and
///     [double] for continuous.
abstract class Scale<V, SV extends num> extends Spec {
  Scale({
    this.formatter,
  });

  final String Function(V)? formatter;
}
