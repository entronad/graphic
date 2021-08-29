import 'package:collection/collection.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:meta/meta.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'aes.dart';

/// To encode one variable to one aes value.
abstract class ChannelAttr<AV> extends Attr<AV> {
  ChannelAttr({
    this.variable,
    this.values,
    this.stops,

    AV? value,
    AV Function(Original)? encode,
    Map<String, Map<bool, SelectUpdate<AV>>>? onSelect,
  }) : super(
    value: value,
    encode: encode,
    onSelect: onSelect,
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

class ChannelEncoder<AV> extends Encoder<AV> {
  ChannelEncoder(this.field, this.conv);

  final String field;

  final ChannelConv<num, AV> conv;

  @override
  AV encode(Scaled scaled, Original original) =>
    conv.convert(scaled[field]!);
}
