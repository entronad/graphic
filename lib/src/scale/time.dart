import 'continuous.dart';

class TimeScale extends ContinuousScale<DateTime> {
  TimeScale({
    DateTime? min,
    DateTime? max,

    String Function(DateTime)? formatter,
  }) : super(
    min: min,
    max: max,
    formatter: formatter,
  );
}
