import 'package:collection/collection.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';

/// An Attr can be determined by algebra/variable, value, or encode, but only one of them can be defined.
/// Attr can be updated by signal or selection.
abstract class Attr<V> {
  Attr({
    this.value,
    this.encode,
    this.signal,
    this.select,
  });

  final V? value;

  final V Function(Tuple)? encode;

  final Signal<V>? signal;

  final Map<Select, SelectUpdate<V>>? select;

  @override
  bool operator ==(Object other) =>
    other is Attr<V> &&
    value == other.value &&
    signal == other.signal &&
    // encode: Function
    DeepCollectionEquality().equals(signal?.keys, other.signal?.keys) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(select?.keys, other.select?.keys);  // SignalUpdata: Function
}
