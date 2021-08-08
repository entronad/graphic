import 'package:collection/collection.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/scale/auto_ticks/cat.dart';

import 'scale.dart';

abstract class DiscreteScale<V> extends Scale<V, int> {
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

  /// List is to emphasize the order. It's better to be distinct.
  final List<V>? values;

  /// How the position will align in the band.
  /// Default is 0.5 in [0, 1].
  final double? align;

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
      values = spec.values;
    } else {
      final candidates = <V>{};
      for (var tuple in tuples) {
        candidates.add(tuple[variable]);
      }
      values = candidates.toList();
    }

    // ticks
    if (spec.ticks != null) {
      ticks = spec.ticks;
    } else {
      ticks = catAutoTicks<V>(
        categories: values!,
        isRounding: spec.tickCount != null,
        maxCount: spec.maxTickCount ?? spec.tickCount,
      );
    }

    title = spec.title ?? variable;
    formatter = spec.formatter ?? defaultFormatter;
    align = align ?? 0.5;
    band = 1 / values!.length;
  }

  List<V>? values;

  double? align;

  double? band;

  @override
  int convert(V input) {
    assert(values!.contains(input));
    return values!.indexOf(input);
  }

  @override
  V invert(int output) {
    assert(output >= 0 && output < values!.length);
    return values![output];
  }

  @override
  double normalize(int scaledValue) =>
    (scaledValue + align!) * band!;

  @override
  int denormalize(double normalValue) =>
    (normalValue / band! - align!).round();
  
  @override
  V get zero => values!.first;
}
