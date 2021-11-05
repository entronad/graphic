import 'dart:math';

extension NumExt on num {
  /// Checks whether this number is between [a] and [b].
  bool between(num a, num b) => this >= min(a, b) && this <= max(a, b);
}

extension DoubleExt on double {
  /// Checks whether this double is equal to [other], avoiding the floating point
  /// error.
  bool equalTo(double other) => (this - other).abs() < 0.0000001;
}
