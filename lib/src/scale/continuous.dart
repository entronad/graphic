import 'scale.dart';

abstract class ContinuousScale<V> extends Scale<V, double> {
  ContinuousScale({
    this.min,
    this.max,

    String Function(V)? formatter,
  }) : super(
    formatter: formatter,
  );

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
  ContinuousScaleConv(this.min, this.max);

  V? min;
  
  V? max;

  @override
  double normalize(double scaledValue) => scaledValue;

  @override
  double denormalize(double normalValue) => normalValue;
}
