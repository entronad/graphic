import 'package:collection/collection.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';

/// An Attr can be determined by algebra/variable, value, or encode, but only one of them can be defined.
/// Attr can be updated by signal or selection.
abstract class Attr<AV> {
  Attr({
    this.value,
    this.encode,
    this.signal,
    this.select,
  });

  final AV? value;

  final AV Function(Tuple)? encode;

  final Signal<AV>? signal;

  final Map<Select, SelectUpdate<AV>>? select;

  @override
  bool operator ==(Object other) =>
    other is Attr<AV> &&
    value == other.value &&
    signal == other.signal &&
    // encode: Function
    DeepCollectionEquality().equals(signal?.keys, other.signal?.keys) &&  // SignalUpdata: Function
    DeepCollectionEquality().equals(select?.keys, other.select?.keys);  // SignalUpdata: Function
}

abstract class AttrConv<SV extends num, AV> extends Converter<SV, AV> {
  @override
  SV invert(AV output) {
    throw UnimplementedError();
  }
}

/// For any attr specification that has value.
class ValueAttrConv<AV> extends AttrConv<num, AV> {
  ValueAttrConv(this.value);

  final AV value;

  @override
  AV convert(num input) => value;
}
