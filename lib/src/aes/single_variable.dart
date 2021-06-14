import 'package:graphic/src/aes/base.dart';
import 'package:graphic/src/control/signal.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/dataflow/tuple.dart';

abstract class SingleVariableAttr<V> extends Attr<V> {
  SingleVariableAttr({
    this.variable,
    this.values,
    this.range,

    V? value,
    Signal<V>? signal,
    V Function(Tuple)? encode
  }) 
    : assert(isSingle([values, range], allowNone: true)),
      super(
        value: value,
        signal: signal,
        encode: encode,
      );

  final String? variable;

  final List<V>? values;

  final List<V>? range;
}
