import 'dart:math';

extension NumExt on num {
  bool between(num a, num b) =>
    this >= min(a, b) && this <= max(a, b);
}
