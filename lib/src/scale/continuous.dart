import 'base.dart';

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
}
