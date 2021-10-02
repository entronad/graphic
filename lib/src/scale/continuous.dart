import 'package:graphic/src/util/assert.dart';

import 'scale.dart';

abstract class ContinuousScale<V> extends Scale<V, double> {
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

  // Can be defined separately.

  V? min;
  
  V? max;

  double? marginMin;

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
