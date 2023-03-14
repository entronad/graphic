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
}
