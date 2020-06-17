import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import '../attrs.dart';

class AnimationCfg {
  AnimationCfg({
    @required this.duration,
    this.curve = Curves.linear,
    this.delay = Duration.zero,
    this.repeat = false,
    this.onFinish,
  });

  final Duration duration;

  final Curve curve;

  final Duration delay;

  final bool repeat;

  final void Function() onFinish;
}

class Animation extends AnimationCfg {
  Animation({
    @required AnimationCfg cfg,
    this.fromAttrs,
    this.toAttrs,
    this.startTime,
    this.onFrame,
  }) : super(
    duration: cfg.duration,
    curve: cfg.curve,
    delay: cfg.delay,
    repeat: cfg.repeat,
    onFinish: cfg.onFinish,
  );

  Attrs fromAttrs;

  Attrs toAttrs;

  Duration startTime;

  Attrs Function(double) onFrame;
}
