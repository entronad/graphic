import 'package:graphic/src/util/assert.dart';
import 'package:meta/meta.dart';

import 'package:graphic/src/common/converter.dart';
import 'package:graphic/src/dataflow/operator/transformer.dart';
import 'package:graphic/src/dataflow/operator/updater.dart';
import 'package:graphic/src/dataflow/pulse/pulse.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/map.dart';

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
  final String? title;

  final String Function(V)? formatter;

  final List<V>? ticks;

  final int? tickCount;

  final int? maxTickCount;

  @override
  bool operator ==(Object other) =>
    other is Scale<V, SV> &&
    title == other.title &&
    // formatter: Function
    ticks == other.ticks &&
    tickCount == other.tickCount &&
    maxTickCount == other.maxTickCount;
}

/// Also act like avatar of a variable, keeps it's meta information.
/// Because scale converter default params is decided by values,
///     it should be completed dynamically. So all params are nullable
///     and filled in complete().
abstract class ScaleConv<V, SV extends num> extends Converter<V, SV> {
  // Fields must be completed in the constructor to make sure it's non-null in run.
  
  String? title;

  String Function(V)? formatter;

  List<V>? ticks;

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
class ScaleConvOp extends Updater<Map<String, ScaleConv>> {
  ScaleConvOp(
    Map<String, dynamic> params,
  ) : super(params, {});

  // must be inited by a pulse.
  @override
  Map<String, ScaleConv> update(Pulse pulse) {
    final specs = params['specs'] as Map<String, Scale>;
    final rst = <String, ScaleConv>{};
    for (var name in specs.keys) {
      final tuples = pulse.source!;
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

/// params:
/// convs: Map<String, ScaleConv>, Scale convertors.
/// relay: Map<Tuple, Tuple>, Relation from original value tuple to scaled value tuple.
/// 
/// pulse:
/// Newly created scaled value pulse form a relay.
/// Tuples are empty but change info is from the orininal value pulse.
class ScaleOp extends Transformer {
  ScaleOp(Map<String, dynamic> params) : super(params);

  @override
  Pulse? transform(Pulse pulse) {
    final convs = params['convs'] as Map<String, ScaleConv>;
    final relay = params['relay'] as Map<Tuple, Tuple>;

    pulse.visit(PulseFlags.add, (tuple) {
      final original = relay.keyOf(tuple);
      for (var field in convs.keys) {
        tuple[field] = convs[field]!.convert(original[field]);
      }
    });

    pulse.visit(PulseFlags.mod, (tuple) {
      final original = relay.keyOf(tuple);
      for (var field in pulse.modFields) {
        tuple[field] = convs[field]!.convert(original[field]);
      }
    });

    return pulse;
  }
}
