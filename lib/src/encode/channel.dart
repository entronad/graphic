import 'package:graphic/src/util/collection.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/interaction/selection/selection.dart';
import 'package:graphic/src/scale/continuous.dart';
import 'package:graphic/src/scale/scale.dart';
import 'package:flutter/foundation.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'encode.dart';

/// The specification of a channel aesthetic encode.
///
/// It encodes a single variable to a value. The encoding will be lerping for continous
/// [variable] scale, and lookup table for discrete scale.
abstract class ChannelEncode<AV> extends Encode<AV> {
  /// Creates a channel aesthetic encode.
  ChannelEncode({
    this.variable,
    this.values,
    this.stops,
    AV? value,
    AV Function(Tuple)? encoder,
    Map<String, Map<bool, SelectionUpdater<AV>>>? updaters,
  })  : assert(values == null || values.length >= 2),
        super(
          value: value,
          encoder: encoder,
          updaters: updaters,
        );

  /// The variable this encode encodes from.
  String? variable;

  /// Target encode values.
  List<AV>? values;

  /// Stops corresponding to [values].
  ///
  /// If null, default average stops will be set.
  List<double>? stops;

  @override
  bool operator ==(Object other) =>
      other is ChannelEncode &&
      super == other &&
      variable == other.variable &&
      deepCollectionEquals(values, other.values) &&
      deepCollectionEquals(stops, other.stops);
}

/// The converter for channel encodes.
///
/// A channel encode encodes values by this converter. it is held by a channel
/// encode's encoder.
///
/// Whether a channel encode's converter is continuous or discrete is determined
/// by its corrsponding variable's scale type.
abstract class ChannelConv<SV extends num, AV> extends Converter<SV, AV> {
  @override
  SV invert(AV output) {
    throw UnimplementedError();
  }
}

/// The continuous channel encode converter.
///
/// Channel encode subtypes need to extend a subclass to implement the [lerp]
/// for their own [AV] types.
abstract class ContinuousChannelConv<AV> extends ChannelConv<double, AV> {
  ContinuousChannelConv(this.values, this.stops)
      : assert(values.length == stops.length);

  /// Target encode values.
  final List<AV> values;

  /// Stops corresponding to [values].
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

  /// Linearly interpolate between two [AV]s.
  @protected
  AV lerp(AV a, AV b, double t);
}

/// The discrete channel encode converter.
///
/// All channel encode subtypes share the same [DiscreteChannelConv].
class DiscreteChannelConv<AV> extends ChannelConv<int, AV> {
  DiscreteChannelConv(this.values);

  /// Target encode values.
  final List<AV> values;

  @override
  AV convert(int input) => values[input];
}

/// The encoder for channel encodes whose [ChannelEncode.variable] is set.
///
/// It holds a [ChannelConv] to encode.
///
/// If a channel encode has [Encode.value] or [Encode.encode] property instead of
/// [ChannelEncode.variable], it will have other corresponding encoder instead of
/// this type.
class ChannelEncoder<AV> extends Encoder<AV> {
  ChannelEncoder(this.variable, this.conv);

  /// The variable this encode encodes from.
  final String variable;

  /// The channel converter.
  final ChannelConv<num, AV> conv;

  @override
  AV encode(Scaled scaled, Tuple tuple) => conv.convert(scaled[variable]!);
}

/// Gets default equidistance stops.
List<double> _defaultStops(int length) {
  final step = 1 / (length - 1);
  final rst = <double>[0];
  for (var i = 1; i < length - 1; i++) {
    rst.add(step * i);
  }
  rst.add(1);
  return rst;
}

/// Gets the encoder of an channel encode.
Encoder<AV> getChannelEncoder<AV>(
  ChannelEncode<AV> spec,
  Map<String, Scale> scaleSpecs,
  ContinuousChannelConv<AV> Function(List<AV>, List<double>)? getContinuousConv,
) {
  if (spec.value != null) {
    return ValueEncodeEncoder<AV>(spec.value as AV);
  }
  if (spec.variable != null) {
    final variable = spec.variable!;
    final scaleSpec = scaleSpecs[variable];
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
    return ChannelEncoder(variable, conv);
  }
  if (spec.encoder != null) {
    return CustomEncoder(spec.encoder!);
  }
  throw ArgumentError('Value, variable, or encode must be set.');
}
