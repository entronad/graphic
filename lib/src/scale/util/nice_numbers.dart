import 'dart:math' as dart_math;

List<num> linearNiceNumbers(
  num min,
  num max,
  int n,
) =>
    _wilkinsonExtended(
      min,
      max,
      n,
      true,
      [1, 5, 2, 2.5, 4, 3],
      [0.25, 0.2, 0.5, 0.05],
    );

const _maxLoop = 10000;

const _esp = 2.220446049250313e-16 * 100;

num _prettyNumber(num n) =>
    n.abs() < 1e-15 ? n : double.parse(n.toStringAsFixed(15));

num _mod(num n, num m) => ((n % m) + m) % m;

num _round(num n) => (n * 1e12).round() / 1e12;

num _simplicity(
  num q,
  List<num> candidates,
  int j,
  num lMin,
  num lMax,
  num lStep,
) {
  final n = candidates.length;
  final i = candidates.indexOf(q);
  int v = 0;
  final m = _mod(lMin, lStep);
  if ((m < _esp || lStep - m < _esp) && lMin <= 0 && lMax >= 0) {
    v = 1;
  }
  return 1 - i / (n - 1) - j + v;
}

num _simplicityMax(
  num q,
  List<num> candidates,
  int j,
) {
  final n = candidates.length;
  final i = candidates.indexOf(q);
  const v = 1;
  return 1 - i / (n - 1) - j + v;
}

num _density(
  int k,
  int m,
  num min,
  num max,
  num lMin,
  num lMax,
) {
  final r = (k - 1) / (lMax - lMin);
  final rt = (m - 1) / (dart_math.max(lMax, max) - dart_math.min(min, lMin));
  return 2 - dart_math.max(r / rt, rt / r);
}

num _densityMax(
  int k,
  int m,
) {
  if (k >= m) {
    return 2 - (k - 1) / (m - 1);
  }
  return 1;
}

num _coverage(
  num min,
  num max,
  num lMin,
  num lMax,
) {
  final range = max - min;
  return 1 -
      (0.5 * (dart_math.pow(max - lMax, 2) + dart_math.pow(min - lMin, 2))) /
          dart_math.pow(0.1 * range, 2);
}

num _coverageMax(
  num min,
  num max,
  num span,
) {
  final range = max - min;
  if (span > range) {
    final half = (span - range) / 2;
    return 1 - dart_math.pow(half, 2) / dart_math.pow(0.1 * range, 2);
  }
  return 1;
}

num _legibility() => 1;

List<num> _wilkinsonExtended(
  num min,
  num max,
  int n,
  bool onlyLoose,
  List<num> candidates,
  List<double> w,
) {
  if (min.isNaN || max.isNaN || n <= 0) {
    return [];
  }

  if (max - min < 1e-15 || n == 1) {
    return [min];
  }

  num bestScore = -2;
  num bestLMin = 0;
  num bestLMax = 0;
  num bestLStep = 0;

  int j = 1;
  while (j < _maxLoop) {
    for (var q in candidates) {
      final sm = _simplicityMax(q, candidates, j);
      if (w[0] * sm + w[1] + w[2] + w[3] < bestScore) {
        j = _maxLoop;
        break;
      }
      int k = 2;
      while (k < _maxLoop) {
        final dm = _densityMax(k, n);
        if (w[0] * sm + w[1] + w[2] * dm + w[3] < bestScore) {
          break;
        }

        final delta = (max - min) / (k + 1) / j / q;
        int z = (dart_math.log(delta) / dart_math.ln10).ceil();

        while (z < _maxLoop) {
          final step = j * q * dart_math.pow(10, z);
          final cm = _coverageMax(min, max, (step * (k - 1)));

          if (w[0] * sm + w[1] * cm + w[2] * dm + w[3] < bestScore) {
            break;
          }

          final minStart = (max / step).floor() * j - (k - 1) * j;
          final maxStart = (min / step).ceil() * j;

          if (minStart <= maxStart) {
            final count = maxStart - minStart;
            for (var i = 0; i <= count; i++) {
              final start = minStart + i;
              final lMin = start * (step / j);
              final lMax = lMin + step * (k - 1);
              final lStep = step;

              final s = _simplicity(q, candidates, j, lMin, lMax, lStep);
              final c = _coverage(min, max, lMin, lMax);
              final g = _density(k, n, min, max, lMin, lMax);
              final l = _legibility();

              final score = w[0] * s + w[1] * c + w[2] * g + w[3] * l;
              if (score > bestScore &&
                  (!onlyLoose || (lMin <= min && lMax >= max))) {
                bestLMin = lMin;
                bestLMax = lMax;
                bestLStep = lStep;
                bestScore = score;
              }
            }
          }
          z += 1;
        }
        k += 1;
      }
    }
    j += 1;
  }

  final lMin = _prettyNumber(bestLMin);
  final lMax = _prettyNumber(bestLMax);
  final lStep = _prettyNumber(bestLStep);

  final tickCount = _round((lMax - lMin) / lStep).floor() + 1;
  final ticks = List<num>.filled(tickCount, 0);

  ticks[0] = _prettyNumber(lMin);
  for (var i = 1; i < tickCount; i++) {
    ticks[i] = _prettyNumber(ticks[i - 1] + lStep);
  }

  return ticks;
}
