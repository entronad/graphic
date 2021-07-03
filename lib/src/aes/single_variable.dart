import 'package:collection/collection.dart';
import 'package:graphic/src/aes/attr.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/dataflow/tuple.dart';

abstract class SingleVariableAttr<V> extends Attr<V> {
  SingleVariableAttr({
    this.variable,
    this.values,
    this.range,

    V? value,
    V Function(Tuple)? encode,
    Signal<V>? signal,
    Map<Select, SelectUpdate<V>>? select,
  }) 
    : assert(isSingle([values, range], allowNone: true)),
      super(
        value: value,
        encode: encode,
        signal: signal,
        select: select,
      );

  final String? variable;

  final List<V>? values;

  final List<V>? range;

  @override
  bool operator ==(Object other) =>
    other is SingleVariableAttr &&
    super == other &&
    variable == other.variable &&
    DeepCollectionEquality().equals(values, other.values) &&
    DeepCollectionEquality().equals(range, other.range);
}
