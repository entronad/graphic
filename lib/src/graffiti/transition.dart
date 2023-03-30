import 'package:flutter/animation.dart';

/// Specifications of a transition animation.
class Transition {
  Transition({
    required this.duration,
    this.curve,
    this.repeat = false,
    this.repeatReverse = false,
  });

  /// the duration of this transition animation.
  final Duration duration;

  /// The curve of this transition animation.
  final Curve? curve;

  /// Whether to repeat this transition animation.
  final bool repeat;

  /// Whether to reverse the repeating of this transition animation.
  final bool repeatReverse;

  @override
  bool operator ==(Object other) =>
      other is Transition &&
      duration == other.duration &&
      curve == other.curve &&
      repeat == other.repeat &&
      repeatReverse == other.repeatReverse;
}
