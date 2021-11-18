import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/shape/shape.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'channel.dart';

/// The specification of a shape attribute.
///
/// Type [S] of the values must belong to the element's geometory type.
class ShapeAttr<S extends Shape> extends ChannelAttr<S> {
  /// Creates a shape attribute.
  ShapeAttr({
    S? value,
    String? variable,
    List<S>? values, // Only descrete.
    S Function(Tuple)? encoder,
    Map<String, Map<bool, SelectionUpdater<S>>>? onSelection,
  })  : assert(isSingle([value, variable, encoder])),
        super(
          value: value,
          variable: variable,
          values: values,
          encoder: encoder,
          onSelection: onSelection,
        );
}
