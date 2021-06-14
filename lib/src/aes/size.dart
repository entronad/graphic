import 'package:graphic/src/control/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'single_variable.dart';

class SizeAttr<D> extends SingleVariableAttr<double> {
  SizeAttr({
    double? value,
    String? variable,
    List<double>? values,
    List<double>? range,
    Signal<double>? signal,
    double Function(Tuple)? encode,
  })
    : assert(isSingle([value, variable, signal, encode])),
      super(
        value: value,
        variable: variable,
        values: values,
        range: range,
        signal: signal,
        encode: encode,
      );
}
