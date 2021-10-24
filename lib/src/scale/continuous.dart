import 'package:graphic/src/util/assert.dart';

import 'scale.dart';

/// The specification of a continuous scale.
/// 
/// A continuous scale converts original tuple values to [double]s normalized to `[0, 1]`.
abstract class ContinuousScale<V> extends Scale<V, double> {
  /// Creates a continuous scale.
  ContinuousScale({
    this.min,
    this.max,
    this.marginMin,
    this.marginMax,

    String? title,
    String Function(V)? formatter,
    List<V>? ticks,
    int? tickCount,
    int? maxTickCount,
  })
    : assert(isSingle([min, marginMin], allowNone: true)),
      assert(isSingle([max, marginMax], allowNone: true)),
      super(
        title: title,
        formatter: formatter,
        ticks: ticks,
        tickCount: tickCount,
        maxTickCount: maxTickCount,
      );

  /// Indicates the minimum input value directly.
  /// 
  /// If null, it will be calculated by minimum input value and [marginMin].
  V? min;
  
  /// Indecates the maximum input value directly.
  /// 
  /// If null, it will be calculated by maximum input value and [marginMax].
  V? max;

  /// The margin ratio form minimum input value to calculated [min].
  double? marginMin;

  /// The margin ratio form maxinum input value to calculated [max].
  double? marginMax;

  @override
  bool operator ==(Object other) =>
    other is ContinuousScale<V> &&
    super == other &&
    min == other.min &&
    max == other.max &&
    marginMin == other.marginMin &&
    marginMax == other.marginMax;
}

abstract class ContinuousScaleConv<V> extends ScaleConv<V, double> {
  V? min;
  
  V? max;

  @override
  double normalize(double scaledValue) => scaledValue;

  @override
  double denormalize(double normalValue) => normalValue;

  @override
  bool operator ==(Object other) =>
    other is ContinuousScaleConv<V> &&
    super == other &&
    min == other.min &&
    max == other.max;
}
