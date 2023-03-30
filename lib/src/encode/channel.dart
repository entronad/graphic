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
abstract class ChannelEncode<EV> extends Encode<EV> {
  /// Creates a channel aesthetic encode.
  ChannelEncode({
    this.variable,
    this.values,
    this.stops,
    EV? value,
    EV Function(Tuple)? encoder,
    Map<String, Map<bool, SelectionUpdater<EV>>>? updaters,
  })  : assert(values == null || values.length >= 2),
        super(
          value: value,
          encoder: encoder,
          updaters: updaters,
        );

  /// The variable this encode encodes from.
  String? variable;

  /// Target encode values.
  List<EV>? values;

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
abstract class ChannelConv<SV extends num, EV> extends Converter<SV, EV> {
  @override
  SV invert(EV output) {
    throw UnimplementedError();
  }
}

/// The continuous channel encode converter.
///
/// Channel encode subtypes need to extend a subclass to implement the [lerp]
/// for their own [EV] types.
abstract class ContinuousChannelConv<EV> extends ChannelConv<double, EV> {
  ContinuousChannelConv(this.values, this.stops)
      : assert(values.length == stops.length);

  /// Target encode values.
  final List<EV> values;

  /// Stops corresponding to [values].
  final List<double> stops;

  @override
  EV convert(double input) {
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

  /// Linearly interpolate between two [EV]s.
  @protected
  EV lerp(EV a, EV b, double t);
}

/// The discrete channel encode converter.
///
/// All channel encode subtypes share the same [DiscreteChannelConv].
class DiscreteChannelConv<EV> extends ChannelConv<int, EV> {
  DiscreteChannelConv(this.values);

  /// Target encode values.
  final List<EV> values;

  @override
  EV convert(int input) => values[input];
}

/// The encoder for channel encodes whose [ChannelEncode.variable] is set.
///
/// It holds a [ChannelConv] to encode.
///
/// If a channel encode has [Encode.value] or [Encode.encode] property instead of
/// [ChannelEncode.variable], it will have other corresponding encoder instead of
/// this type.
class ChannelEncoder<EV> extends Encoder<EV> {
  ChannelEncoder(this.variable, this.conv);

  /// The variable this encode encodes from.
  final String variable;

  /// The channel converter.
  final ChannelConv<num, EV> conv;

  @override
  EV encode(Scaled scaled, Tuple tuple) => conv.convert(scaled[variable]!);
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
Encoder<EV> getChannelEncoder<EV>(
  ChannelEncode<EV> spec,
  Map<String, Scale> scaleSpecs,
  ContinuousChannelConv<EV> Function(List<EV>, List<double>)? getContinuousConv,
) {
  if (spec.value != null) {
    return ValueEncodeEncoder<EV>(spec.value as EV);
  }
  if (spec.variable != null) {
    final variable = spec.variable!;
    final scaleSpec = scaleSpecs[variable];
    ChannelConv<num, EV> conv;
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
