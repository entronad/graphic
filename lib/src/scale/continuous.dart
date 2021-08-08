import 'scale.dart';

abstract class ContinuousScale<V> extends Scale<V, double> {
  ContinuousScale({
    this.min,
    this.max,

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

  // Can be defined separately.

  final V? min;
  
  final V? max;

  @override
  bool operator ==(Object other) =>
    other is ContinuousScale<V> &&
    super == other &&
    min == other.min &&
    max == other.max;
}

abstract class ContinuousScaleConv<V> extends ScaleConv<V, double> {
  V? min;
  
  V? max;

  @override
  double normalize(double scaledValue) => scaledValue;

  @override
  double denormalize(double normalValue) => normalValue;
}
