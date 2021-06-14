import 'package:graphic/src/control/signal.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/dataflow/tuple.dart';

/// An Attr can be determined by algebra/variable, value, signal, or encode, but only one of them can be defined.
abstract class Attr<V> extends Spec {
  Attr({
    this.value,
    this.signal,
    this.encode,
  });

  final V? value;

  final Signal<V>? signal;

  final V Function(Tuple)? encode;
}
