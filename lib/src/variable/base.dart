import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/scale/base.dart';

typedef Accessor<D, V> = V Function(D);

/// [D]: Type of source data items.
/// [V]: Type of variable value.
class Variable<D, V> extends Spec {
  Variable({
    required this.accessor,
    this.scale,
  });

  final Accessor<D, V>? accessor;

  /// If not provided, a default scale is infered from the type of [V].
  ///     [OrdinalScale] for [String]
  ///     [LinearScale] for [num]
  ///     [TimeScale] for [DateTime]
  final Scale<V, dynamic>? scale;
}
