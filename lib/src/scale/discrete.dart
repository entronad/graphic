import 'package:collection/collection.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/auto_ticks/cat.dart';

import 'scale.dart';

/// The specification of a discrete scale.
/// 
/// A discrete scale converts original tuple values to [int]s of natural number.
abstract class DiscreteScale<V> extends Scale<V, int> {
  /// Creates a discrete scale.
  DiscreteScale({
    this.values,
    this.align,

    String? title,
    String Function(V)? formatter,
    List<V>? ticks,
    int? tickCount,
    int? maxTickCount,
  }) : super(
    title: title,
    formatter: formatter,
    ticks: ticks,
    tickCount: tickCount,
    maxTickCount: maxTickCount,
  );

  /// Candidate values.
  /// 
  /// It is a [List] not a [Set] because the values must has an order for position.
  /// But it's better that each value occurs only once.
  List<V>? values;

  /// The align ratio of the exact position in the value position band.
  /// 
  /// If null, a default 0.5 is set, which means in the middle of the band.
  double? align;

  @override
  bool operator ==(Object other) =>
    other is DiscreteScale<V> &&
    super == other &&
    DeepCollectionEquality().equals(values, other.values) &&
    align == other.align;
}

abstract class DiscreteScaleConv<V, SP extends DiscreteScale<V>> extends ScaleConv<V, int> {
  DiscreteScaleConv(
    SP spec,
    List<Tuple> tuples,
    String variable,
  ) {
    // values
    if (spec.values != null) {
      values = spec.values!;
    } else {
      final candidates = <V>{};
      for (var tuple in tuples) {
        candidates.add(tuple[variable]);
      }
      values = candidates.toList();
    }

    // ticks
    if (spec.ticks != null) {
      ticks = spec.ticks!;
    } else {
      ticks = catAutoTicks<V>(
        categories: values,
        isRounding: spec.tickCount != null,
        maxCount: spec.maxTickCount ?? spec.tickCount,
      );
    }

    title = spec.title ?? variable;
    formatter = spec.formatter ?? defaultFormatter;
    align = spec.align ?? 0.5;
    band = 1 / values.length;
  }

  late List<V> values;

  late double align;

  late double band;

  @override
  int convert(V input) {
    assert(values.contains(input));
    return values.indexOf(input);
  }

  @override
  V invert(int output) {
    assert(output >= 0 && output < values.length);
    return values[output];
  }

  @override
  double normalize(int scaledValue) =>
    (scaledValue + align) * band;

  @override
  int denormalize(double normalValue) =>
    (normalValue / band - align).round();
  
  @override
  V get zero => values.first;

  @override
  bool operator ==(Object other) =>
    other is DiscreteScaleConv<V, SP> &&
    super == other &&
    DeepCollectionEquality().equals(values, other.values) &&
    align == other.align &&
    band == other.band;
}
