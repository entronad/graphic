import 'dart:math' as dart_math;

import '../linear.dart';

final _e10 = dart_math.sqrt(50);
final _e5 = dart_math.sqrt(10);
final _e2 = dart_math.sqrt(2);

num _tickIncrement(
  num start,
  num stop,
  int count,
) {
  final step = (stop - start) / dart_math.max(0, count);
  final power = (dart_math.log(step) / dart_math.ln10).floor();
  final error = step / dart_math.pow(10, power);
  if (power >= 0) {
    return (error >= _e10
            ? 10
            : error >= _e5
                ? 5
                : error >= _e2
                    ? 2
                    : 1) *
        dart_math.pow(10, power);
  }
  return -dart_math.pow(10, -power) /
      (error >= _e10
          ? 10
          : error >= _e5
              ? 5
              : error >= _e2
                  ? 2
                  : 1);
}

/// Calculates nice range for [LinearScaleConv].
List<num> linearNiceRange(
  num min,
  num max,
  int count,
) {
  // From d3-scale.

  final d = [min, max];
  int i0 = 0;
  int i1 = d.length - 1;
  num start = d[i0];
  num stop = d[i1];
  late num step;

  if (stop < start) {
    final tempValue = start;
    start = stop;
    stop = tempValue;
    final tempIndex = i0;
    i0 = i1;
    i1 = tempIndex;
  }

  // If min and max are same, return directly.
  if (stop - start < 1e-15 || count <= 0) {
    return [start, stop];
  }

  step = _tickIncrement(start, stop, count);

  if (step > 0) {
    start = (start / step).floor() * step;
    stop = (stop / step).ceil() * step;
    step = _tickIncrement(start, stop, count);
  } else if (step < 0) {
    start = (start * step).ceil() / step;
    stop = (stop * step).floor() / step;
    step = _tickIncrement(start, stop, count);
  }

  if (step > 0) {
    d[i0] = (start / step).floor() * step;
    d[i1] = (stop / step).ceil() * step;
  } else if (step < 0) {
    d[i0] = (start * step).ceil() / step;
    d[i1] = (stop * step).floor() / step;
  }
  return d;
}
