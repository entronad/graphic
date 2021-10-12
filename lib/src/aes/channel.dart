import 'package:collection/collection.dart';
import 'package:graphic/src/interaction/select/select.dart';
import 'package:graphic/src/scale/continuous.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:flutter/foundation.dart';
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
  })
    : assert(values == null || values.length >= 2),
      super(
        value: value,
        encode: encode,
        onSelect: onSelect,
      );

  String? variable;

  /// Used as gradient stop values for continuous
  ///     and lookup table for discrete.
  List<AV>? values;

  /// Gradient stops when continuous, must have same length to values.
  /// Stops can be decreasing for inverse mapping.
  List<double>? stops;

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

List<double> _defaultStops(int length) {
  final step = 1 / (length - 1);
  final rst = <double>[0];
  for (var i = 1; i < length - 1; i++) {
    rst.add(step * i);
  }
  rst.add(1);
  return rst;
}

Encoder<AV> getChannelEncoder<AV>(
  ChannelAttr<AV> spec,
  Map<String, Scale> scaleSpecs,
  ContinuousChannelConv<AV> Function(List<AV>, List<double>)? getContinuousConv,
) {
  if (spec.value != null) {
    return ValueAttrEncoder<AV>(spec.value!);
  }
  if (spec.variable != null) {
    final field = spec.variable!;
    final scaleSpec = scaleSpecs[field];
    ChannelConv<num, AV> conv;
    if (scaleSpec is ContinuousScale) {
      assert(getContinuousConv != null, '$spec dose not support continuous.');
      conv = getContinuousConv!(
        spec.values!,
        spec.stops ?? _defaultStops(spec.values!.length),
      );
    } else {
      conv = DiscreteChannelConv(spec.values!);
    }
    return ChannelEncoder(field, conv);
  }
  if (spec.encode != null) {
    return CustomEncoder(spec.encode!);
  }
  throw ArgumentError('Value, variable, or encode must be set.');
}
