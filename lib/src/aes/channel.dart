import 'package:collection/collection.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/map.dart';

import 'aes.dart';

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

/// params:
/// - attr: String, Aes value this operator handles.
/// - variable: String, Scaled value tuple field.
/// - conv: ChannelConv<AV>
/// - aesRelay: Map<Tuple, Tuple>, Relay from scaled value to aes value.
class ChannelOp<AV> extends AesOp<AV> {
  ChannelOp(
    Map<String, dynamic> params,
    String attr,
  ) : super(params, attr);

  @override
  void aes(Tuple tuple) {
    final variable = params['variable'] as String;
    final conv = params['conv'] as ChannelConv<num, AV>;
    final aesRelay = params['aesRelay'] as Map<Tuple, Tuple>;

    final scaledTuple = aesRelay.keyOf(tuple);
    tuple[attr] = conv.convert(scaledTuple[variable]);
  }
}
