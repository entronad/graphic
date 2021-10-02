import 'dart:math';

extension NumExt on num {
  bool between(num a, num b) =>
    this >= min(a, b) && this <= max(a, b);
}

extension DoubleExt on double {
  bool equalTo(double other) =>
    (this - other).abs() < 0.0000001;
}
