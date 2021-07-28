import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:graphic/src/event/selection/select.dart';
import 'package:graphic/src/event/signal.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/map.dart';

import 'aes.dart';

/// To encode one variable to one aes value.
abstract class ChannelAttr<AV> extends Attr<AV> {
  ChannelAttr({
    this.variable,
    this.values,
    this.stops,

    AV? value,
    AV Function(Tuple)? encode,
    Signal<AV>? signal,
    Map<Select, SelectUpdate<AV>>? select,
  }) : super(
    value: value,
    encode: encode,
    signal: signal,
    select: select,
  );

  final String? variable;

  /// Used as gradient stop values for continuous
  ///     and lookup table for discrete.
  final List<AV>? values;

  /// Gradient stops when continuous, must have same length to values.
  /// Stops can be decreasing for inverse mapping.
  final List<double>? stops;

  @override
  bool operator ==(Object other) =>
    other is ChannelAttr &&
    super == other &&
    variable == other.variable &&
    DeepCollectionEquality().equals(values, other.values) &&
    DeepCollectionEquality().equals(stops, other.stops);
}

/// Wheather continuous or discrete will be decided by the scale of the variable.
abstract class ChannelConv<SV extends num, AV> extends AttrConv<SV, AV> {}

abstract class ContinuousChannelConv<AV> extends ChannelConv<double, AV> {
  ContinuousChannelConv(this.values, this.stops)
    : assert(values.length == stops.length);

  final List<AV> values;

  final List<double> stops;

  @override
  AV convert(double input) {
    if (stops.first <= stops.last) {
      for (var s = 0; s < stops.length - 1; s++) {
        final leftStop = stops[s];
        final rightStop = stops[s + 1];
        final leftValue = values[s];
        final rightValue = values[s + 1];
        if (input <= leftStop) {
          return leftValue;
        } else if (input < rightStop) {
          final sectionT = (input - leftStop) / (rightStop - leftStop);
          return lerp(leftValue, rightValue, sectionT);
        }
      }
      return values.last;
    } else {
      for (var s = 0; s < stops.length - 1; s++) {
        final leftStop = stops[s];
        final rightStop = stops[s + 1];
        final leftValue = values[s];
        final rightValue = values[s + 1];
        if (input >= leftStop) {
          return leftValue;
        } else if (input > rightStop) {
          final sectionT = (input - leftStop) / (rightStop - leftStop);
          return lerp(leftValue, rightValue, sectionT);
        }
      }
      return values.last;
    }
  }

  @protected
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
