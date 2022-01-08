import 'package:graphic/src/util/collection.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/guide/axis/axis.dart';
import 'package:graphic/src/guide/interaction/tooltip.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:flutter/foundation.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/variable/variable.dart';

import 'discrete.dart';
import 'continuous.dart';
import 'ordinal.dart';
import 'linear.dart';
import 'time.dart';

/// The specification of a scale.
///
/// A scale converts original tuple values to scaled values. For [DiscreteScale],
/// the scaled value is an [int] of natural number, and for [ContinuousScale] is
/// a [double] normalized to `[0, 1]`.
///
/// Besides, variable meta data and axis tick settings are also specified in it's
/// scale.
///
/// The generic [V] is the type of original value, and [SV] is the type of scaled
/// value.
///
/// See also:
///
/// - [Variable], a scale corresponds to a variable.
/// - [AxisGuide], axis tick settings are specified the scale.
abstract class Scale<V, SV extends num> {
  /// Creates a scale.
  Scale({
    this.title,
    this.formatter,
    this.ticks,
    this.tickCount,
  }) : assert(isSingle([ticks, tickCount], allowNone: true));

  /// Title of the variable this scale corresponds to.
  ///
  /// It represents the variable in [TooltipGuide], etc.
  ///
  /// If null, it will be the same as variable name identifier.
  String? title;

  /// Convert the value to a [String] on the chart.
  ///
  /// If null, a default [Object.toString] is used.
  String Function(V)? formatter;

  /// Indicates the axis ticks directly.
  List<V>? ticks;

  /// The desired count of axis ticks.
  ///
  /// The final tick count, calculated with nice numbers algorithm, may be more
  /// or less than this setting.
  ///
  /// If null, a default 5 will be set for [ContinuousScale] and [DiscreteScale]
  /// will show all ticks.
  int? tickCount;

  @override
  bool operator ==(Object other) =>
      other is Scale<V, SV> &&
      title == other.title &&
      deepCollectionEquals(ticks, other.ticks) &&
      tickCount == other.tickCount;
}

/// The scale converter.
///
/// It also acts like avatar of a variable, carring the meta information like [title],
/// [formatter], and [ticks] of the scale.
///
/// Because the default values are relatied to tuple values, it is initialized in
/// the constructor body.
abstract class ScaleConv<V, SV extends num> extends Converter<V, SV> {
  /// the scale title.
  ///
  /// Two scale converters equlity check does not involve titles.
  late String title;

  /// The scale formatter
  ///
  /// This should not be directly used. Use method [format] insead to avoid generic
  /// problems.
  late String Function(V) formatter;

  /// The scale ticks.
  late List<V> ticks;

  /// Normalizes a scaled value to [0, 1].
  ///
  /// It is usefull for [DiscreteScale], which scale value to natural number while
  /// position requires a normalized value.
  double normalize(SV scaledValue);

  /// De-normalizes a [0, 1] value to scaled value.
  ///
  /// It is usefull for [DiscreteScale], which scale value to natural number while
  /// position requires a normalized value.
  SV denormalize(double normalValue);

  /// Normalized value of zero.
  ///
  /// It is usefull to compose the position of coordinate origin point or geom completing
  /// points.
  double get normalZero => normalize(convert(zero));

  /// The zero of [V].
  @protected
  V get zero;

  /// Formats a value to string.
  ///
  /// This is a method wrapper of [formatter] to avoid generic problems.
  String format(V value) => formatter(value);

  /// The default formatter of [V] for [formatter].
  @protected
  String defaultFormatter(V value);

  @override
  bool operator ==(Object other) =>
      other is ScaleConv<V, SV> && deepCollectionEquals(ticks, other.ticks);
}

/// The operator to create scale converters.
class ScaleConvOp extends Operator<Map<String, ScaleConv>> {
  ScaleConvOp(
    Map<String, dynamic> params,
  ) : super(params, {});

  @override
  Map<String, ScaleConv> evaluate() {
    final tuples = params['tuples'] as List<Tuple>;
    final specs = params['specs'] as Map<String, Scale>;

    final rst = <String, ScaleConv>{};
    for (var name in specs.keys) {
      if (specs[name] is OrdinalScale) {
        final spec = specs[name] as OrdinalScale;
        rst[name] = OrdinalScaleConv(spec, tuples, name);
      } else if (specs[name] is LinearScale) {
        final spec = specs[name] as LinearScale;
        rst[name] = LinearScaleConv(spec, tuples, name);
      } else if (specs[name] is TimeScale) {
        final spec = specs[name] as TimeScale;
        rst[name] = TimeScaleConv(spec, tuples, name);
      }
    }
    return rst;
  }
}

/// The operator to convert original value tuples to scaled valaue tuples by scales.
class ScaleOp extends Operator<List<Scaled>> {
  ScaleOp(Map<String, dynamic> params) : super(params);

  @override
  List<Scaled> evaluate() {
    final tuples = params['tuples'] as List<Tuple>;
    final convs = params['convs'] as Map<String, ScaleConv>;

    return tuples.map((tuple) {
      final scaled = Scaled();
      for (var field in convs.keys) {
        scaled[field] = convs[field]!.convert(tuple[field]);
      }
      return scaled;
    }).toList();
  }
}
