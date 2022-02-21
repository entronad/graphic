import 'package:graphic/src/util/collection.dart';
import 'package:graphic/src/dataflow/tuple.dart';
import 'package:graphic/src/util/assert.dart';

import 'scale.dart';

/// The specification of a discrete scale.
///
/// A discrete scale converts original tuple values to [int]s of natural number.
abstract class DiscreteScale<V> extends Scale<V, int> {
  /// Creates a discrete scale.
  DiscreteScale({
    this.values,
    this.inflate,
    this.align,
    String? title,
    String? Function(V)? formatter,
    List<V>? ticks,
    int? tickCount,
  })  : assert(isSingle([inflate, align], allowNone: true)),
        super(
          title: title,
          formatter: formatter,
          ticks: ticks,
          tickCount: tickCount,
        );

  /// The candidate values.
  ///
  /// It is a [List] not a [Set] because the values must has an order for position.
  /// But it's better that each value occurs only once.
  List<V>? values;

  /// Whether the points distribution will inflate the axis range.
  ///
  /// If true, The points will distribute in the axis range from end to end, with
  /// equal intervals. The [align] is not allowd then.
  bool? inflate;

  /// The align ratio of the exact position in the value position band.
  ///
  /// If null, a default 0.5 is set, which means in the middle of the band.
  double? align;

  @override
  bool operator ==(Object other) =>
      other is DiscreteScale<V> &&
      super == other &&
      deepCollectionEquals(values, other.values) &&
      inflate == other.inflate &&
      align == other.align;
}

/// The discrete scale converter.
abstract class DiscreteScaleConv<V, SP extends DiscreteScale<V>>
    extends ScaleConv<V, int> {
  DiscreteScaleConv(
    SP spec,
    List<Tuple> tuples,
    String variable,
  ) {
    if (spec.values != null) {
      values = spec.values!;
    } else {
      final candidates = <V>{};
      for (var tuple in tuples) {
        candidates.add(tuple[variable]);
      }
      values = candidates.toList();
    }

    if (spec.ticks != null) {
      ticks = spec.ticks!;
    } else if (spec.tickCount == null || spec.tickCount! >= values.length) {
      ticks = values;
    } else if (spec.tickCount! <= 0) {
      ticks = [];
    } else {
      final step = (values.length / spec.tickCount!).ceil();
      final tail = (values.length - 1) % step;
      int index = tail ~/ 2;
      ticks = [];
      while (index < values.length) {
        ticks.add(values[index]);
        index += step;
      }
    }

    title = spec.title ?? variable;
    formatter = spec.formatter ?? defaultFormatter;
    inflate = spec.inflate ?? false;
    band = inflate ? 1 / (values.length - 1) : 1 / values.length;
    align = inflate ? 0 : spec.align ?? 0.5;
  }

  /// The candidate values.
  late List<V> values;

  /// Whether to inflate the axis range.
  late bool inflate;

  /// The align ratio.
  late double align;

  /// The band ratio of each value.
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
  double normalize(int scaledValue) => (scaledValue + align) * band;

  @override
  int denormalize(double normalValue) => (normalValue / band - align).round();

  @override
  V get zero => values.first;

  @override
  bool operator ==(Object other) =>
      other is DiscreteScaleConv<V, SP> &&
      super == other &&
      deepCollectionEquals(values, other.values) &&
      align == other.align &&
      band == other.band;
}
