import 'package:graphic/src/dataflow/tuple.dart';

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

DateTime _later(DateTime a, DateTime b) =>
  a.isAfter(b) ? a : b;

DateTime _earlier(DateTime a, DateTime b) =>
  a.isBefore(b) ? a : b;

class TimeScaleConv extends ContinuousScaleConv<DateTime> {
  TimeScaleConv(
    DateTime? min,
    DateTime? max,
  ) : super(min, max);

  @override
  double convert(DateTime input) =>
    (input.microsecondsSinceEpoch - min!.microsecondsSinceEpoch) /
    (max!.microsecondsSinceEpoch - min!.microsecondsSinceEpoch);

  @override
  DateTime invert(double output) =>
    DateTime.fromMicrosecondsSinceEpoch((
      min!.microsecondsSinceEpoch +
      output * (max!.microsecondsSinceEpoch - min!.microsecondsSinceEpoch)
    ).round());
  
  @override
  void complete(List<Tuple> tuples, String field) {
    if (min == null || max == null) {
      var minTmp = tuples.first[field] as DateTime;
      var maxTmp = minTmp;
      for (var tuple in tuples) {
        final value = tuple[field] as DateTime;
        minTmp = _earlier(minTmp, value);
        maxTmp = _later(maxTmp, value);
      }
      min = min ?? minTmp;
      max = max ?? maxTmp;
    }
  }
}
