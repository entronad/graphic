import 'package:flutter/animation.dart';

class Transition {
  Transition({
    required this.duration,
    this.curve,
    this.repeat = false,
    this.repeatReverse = false,
  });

  final Duration duration;

  final Curve? curve;

  final bool repeat;

  final bool repeatReverse;

  @override
  bool operator ==(Object other) =>
      other is Transition &&
      duration == other.duration &&
      curve == other.curve &&
      repeat == other.repeat &&
      repeatReverse == other.repeatReverse;
}
