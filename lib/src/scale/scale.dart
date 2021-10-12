import 'package:collection/collection.dart';
import 'package:graphic/src/chart/view.dart';
import 'package:graphic/src/dataflow/operator.dart';
import 'package:graphic/src/parse/parse.dart';
import 'package:graphic/src/parse/spec.dart';
import 'package:graphic/src/util/assert.dart';
import 'package:flutter/foundation.dart';
import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/tuple.dart';

import 'ordinal.dart';
import 'linear.dart';
import 'time.dart';

/// [V]: Type of input variable value.
/// [SV]: Type of scaled value result,
///     [int] for discrete and
///     [double] for continuous.
abstract class Scale<V, SV extends num> {
  Scale({
    this.title,
    this.formatter,
    this.ticks,
    this.tickCount,
    this.maxTickCount,
  }) : assert(isSingle([ticks, tickCount, maxTickCount], allowNone: true));

  /// To represent this variable in tooltip/legend/label/tag.
  /// Default to use the name of the variable.
  String? title;

  String Function(V)? formatter;

  List<V>? ticks;

  int? tickCount;

  int? maxTickCount;

  @override
  bool operator ==(Object other) =>
    other is Scale<V, SV> &&
    title == other.title &&
    // formatter: Function
    DeepCollectionEquality().equals(ticks, other.ticks) &&
    tickCount == other.tickCount &&
    maxTickCount == other.maxTickCount;
}

/// Also act like avatar of a variable, keeps it's meta information.
/// Because scale converter default params is decided by values,
///     it should be completed dynamically. So all params are nullable
///     and filled in complete().
abstract class ScaleConv<V, SV extends num> extends Converter<V, SV> {
  // Fields must be completed in the constructor to make sure it's non-null in run.
  
  late String title;

  late String Function(V) formatter;

  late List<V> ticks;

  /// Normalize scaled value to [0, 1]
  double normalize(SV scaledValue);

  /// De-normalize normal value to scaled value.
  SV denormalize(double normalValue);

  /// Normalized value of zero, used to compose the normal
  ///     origin point of coord, and complete geom points.
  double get normalZero =>
    normalize(convert(zero));

  @protected
  V get zero;

  @protected
  String defaultFormatter(V value);

  @override
  bool operator ==(Object other) =>
    other is ScaleConv<V, SV> &&
    // title don't need to be equal.
    // formatter: Function
    DeepCollectionEquality().equals(ticks, other.ticks);
}

/// params:
/// - specs: Map<String, Scale>, Scale specs of all variables.
/// 
/// pulse:
/// Original value pulse before scale,
/// Only has rem to clear pre tuples and add to add new tuples.
/// 
/// value: Map<String, ScaleConv>
/// Scale converter of all variables.
class ScaleConvOp extends Operator<Map<String, ScaleConv>> {
  ScaleConvOp(
    Map<String, dynamic> params,
  ) : super(params, {});

  @override
  Map<String, ScaleConv> evaluate() {
    final originals = params['originals'] as List<Original>;
    final specs = params['specs'] as Map<String, Scale>;

    final rst = <String, ScaleConv>{};
    for (var name in specs.keys) {
      if (specs[name] is OrdinalScale) {
        final spec = specs[name] as OrdinalScale;
        rst[name] = OrdinalScaleConv(spec, originals, name);
      } else if (specs[name] is LinearScale) {
        final spec = specs[name] as LinearScale;
        rst[name] = LinearScaleConv(spec, originals, name);
      } else if (specs[name] is TimeScale) {
        final spec = specs[name] as TimeScale;
        rst[name] = TimeScaleConv(spec, originals, name);
      }
    }
    return rst;
  }
}

/// params:
/// convs: Map<String, ScaleConv>, Scale convertors.
/// relay: Map<Tuple, Tuple>, Relation from original value tuple to scaled value tuple.
/// 
/// pulse:
/// Newly created scaled value pulse form a relay.
/// Tuples are empty but change info is from the orininal value pulse.
class ScaleOp extends Operator<List<Scaled>> {
  ScaleOp(Map<String, dynamic> params) : super(params);

  @override
  List<Scaled> evaluate() {
    final originals = params['originals'] as List<Original>;  // From original collect operator.
    final convs = params['convs'] as Map<String, ScaleConv>;

    return originals.map((original) {
      final scaled = Scaled();
      for (var field in convs.keys) {
        scaled[field] = convs[field]!.convert(original[field]);
      }
      return scaled;
    }).toList();
  }
}

void parseScale(
  Spec spec,
  View view,
  Scope scope,
) {
  scope.scales = view.add(ScaleConvOp({
    'originals': scope.originals,
    'specs': scope.scaleSpecs,
  }));

  scope.scaleds = view.add(ScaleOp({
    'originals': scope.originals,
    'convs': scope.scales,
  }));
}
