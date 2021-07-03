import 'package:graphic/src/scale/scale.dart';

typedef Accessor<D, V> = V Function(D);

/// [D]: Type of source data items.
/// [V]: Type of variable value.
class Variable<D, V> {
  Variable({
    required this.accessor,
    this.scale,
    this.title,
  });

  final Accessor<D, V>? accessor;

  /// If not provided, a default scale is infered from the type of [V].
  ///     [OrdinalScale] for [String]
  ///     [LinearScale] for [num]
  ///     [TimeScale] for [DateTime]
  final Scale<V, dynamic>? scale;

  /// To represent this variable in tooltip/legend/label/tag.
  /// Default to use the name of the variable.
  final String? title;

  @override
  bool operator ==(Object other) =>
    other is Variable<D, V> &&
    // accessor: Function
    scale == other.scale &&
    title == other.title;
}
