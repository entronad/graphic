import 'continuous.dart';

class LinearScale extends ContinuousScale<num> {
  LinearScale({
    double? min,
    double? max,

    String Function(num)? formatter,
  }) : super(
    min: min,
    max: max,
    formatter: formatter,
  );
}
