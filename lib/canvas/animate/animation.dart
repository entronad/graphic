import 'dart:ui' show VoidCallback;

import 'package:flutter/animation.dart' show Curve, Curves;
import 'package:flutter/foundation.dart' show required;
import 'package:flutter/widgets.dart' show UniqueKey;

import '../attrs.dart' show Attrs;

class AnimationCfg {
  AnimationCfg({
    @required this.duration,
    this.curve = Curves.linear,
    this.delay = Duration.zero,
    this.repeat = false,
    this.onFinish,
    this.onPause,
    this.onResume,
  });

  final Duration duration;

  final Curve curve;

  final Duration delay;

  final bool repeat;

  final VoidCallback onFinish;

  final VoidCallback onPause;

  final VoidCallback onResume;
}

typedef OnFrame = Attrs Function(double ratio);

class Animation extends AnimationCfg {
  Animation({
    @required AnimationCfg cfg,
    this.id,
    this.fromAttrs,
    this.toAttrs,
    this.startTime,
    this.pathFormatted,
    this.onFrame,
    this.paused,
    this.pauseTime,
  }) : super(
    duration: cfg.duration,
    curve: cfg.curve,
    delay: cfg.delay,
    repeat: cfg.repeat,
    onFinish: cfg.onFinish,
    onPause: cfg.onPause,
    onResume: cfg.onResume,
  );

  UniqueKey id;

  Attrs fromAttrs;

  Attrs toAttrs;

  Duration startTime;

  bool pathFormatted;

  OnFrame onFrame;

  bool paused;

  Duration pauseTime;
}
