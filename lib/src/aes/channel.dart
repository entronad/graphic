import 'package:collection/collection.dart';
import 'package:graphic/src/aes/attr.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/dataflow/tuple.dart';

/// To encode one variable to one aes value.
abstract class ChannelAttr<AV> extends Attr<AV> {
  ChannelAttr({
    this.variable,
    this.values,
    this.range,

    AV? value,
    AV Function(Tuple)? encode,
    Signal<AV>? signal,
    Map<Select, SelectUpdate<AV>>? select,
  }) 
    : assert(isSingle([values, range], allowNone: true)),
      assert(range == null || range.length == 2),
      super(
        value: value,
        encode: encode,
        signal: signal,
        select: select,
      );

  final String? variable;

  final List<AV>? values;

  final List<AV>? range;

  @override
  bool operator ==(Object other) =>
    other is ChannelAttr &&
    super == other &&
    variable == other.variable &&
    DeepCollectionEquality().equals(values, other.values) &&
    DeepCollectionEquality().equals(range, other.range);
}

abstract class ChannelConv<SV extends num, AV> extends AttrConv<SV, AV> {}

abstract class ContinuousChannelConv<AV> extends ChannelConv<double, AV> {
  ContinuousChannelConv(this.range);

  final List<AV> range;

  @override
  AV convert(double input) => lerp(range.first, range.last, input);

  AV lerp(AV a, AV b, double t);
}

/// For any attr specification that has values and discrete input variable scale.
class DiscreteChannelConv<AV> extends ChannelConv<int, AV> {
  DiscreteChannelConv(this.values);

  final List<AV> values;

  @override
  AV convert(int input) => values[input];
}
