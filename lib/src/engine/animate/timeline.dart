import 'dart:ui';

import 'package:flutter/scheduler.dart';

import '../util/matrix.dart';
import '../renderer.dart';
import '../element.dart';
import 'animation.dart';
import '../attrs.dart';

void _update(Element shape, Animation animation, double ratio) {
  if (shape.destroyed) {
    return;
  }
  final fromAttrs = animation.fromAttrs;
  final toAttrs = animation.toAttrs;
  final cProps = Attrs();
  for (var key in toAttrs.keys) {
      final fromValue = fromAttrs[key];
      final toValue = toAttrs[key];
      if (fromValue == null || fromValue == toValue) {
        cProps[key] = toValue;
        continue;
      }
      if (toValue is double) {
        cProps[key] = (toValue - (fromValue as double)) * ratio + (fromValue as double);
        continue;
      }
      if (toValue is Color) {
        cProps[key] = Color.lerp(fromValue, toValue, ratio);
        continue;
      }
      if (toValue is Matrix) {
        cProps[key] = (toValue - (fromValue as Matrix)) * ratio + (fromValue as Matrix);
        continue;
      }
      if (toValue is List<Offset>) {
        final fromPoints = fromValue as List<Offset>;
        final toPoints = toValue;
        final lerpedPoints = <Offset>[];
        for (var i = 0; i < toPoints.length; i++) {
          if (fromPoints[i] != null) {
            lerpedPoints.add(Offset.lerp(fromPoints[i], toPoints[i], ratio));
          } else {
            lerpedPoints.add(toPoints[i]);
          }
        }
        cProps[key] = lerpedPoints;
        continue;
      }
      cProps[key] = toValue;
    }
  shape.attr(cProps);
}

bool update(Element shape, Animation animation, Duration elapsed) {
  final startTime = animation.startTime;
  final delay = animation.delay;
  if (elapsed < startTime + delay) {
    return false;
  }
  double ratio;
  final duration = animation.duration;
  final curve = animation.curve;
  elapsed = elapsed - startTime - delay;
  if (animation.repeat) {
    ratio = (elapsed.inMicroseconds % duration.inMicroseconds) / duration.inMicroseconds;
    ratio = curve.transform(ratio);
  } else {
    ratio = elapsed.inMicroseconds / duration.inMicroseconds;
    if (ratio < 1) {
      ratio = curve.transform(ratio);
    } else {
      if (animation.onFrame != null) {
        shape.attr(animation.onFrame(1));
      } else {
        shape.attr(animation.toAttrs);
      }
      return true;
    }
  }
  if (animation.onFrame != null) {
    final attrs = animation.onFrame(ratio);
    shape.attr(attrs);
  } else {
    _update(shape, animation, ratio);
  }
  return false;
}

class Timeline {
  Timeline(this.renderer);

  Renderer renderer;

  final List<Element> animators = [];

  Duration current = Duration.zero;

  Ticker ticker;

  // void initTicker() {
  //   var isFinished = false;
  //   Element shape;
  //   List<Animation> animations;
  //   Animation animation;
  //   ticker = renderer.tickerProvider.createTicker((elapsed) {
  //     current = elapsed;
  //     if (animators.isNotEmpty) {
  //       for (var i = animators.length - 1; i >= 0; i--) {
  //         shape = animators[i];
  //         if (shape.destroyed) {
  //           removeAnimator(i);
  //           continue;
  //         }
  //         animations = shape.cfg.animations;
  //         for (var j = animations.length - 1; j >= 0; j--) {
  //           animation = animations[j];
  //           isFinished = update(shape, animation, elapsed);
  //           if (isFinished) {
  //             animations.removeAt(j);
  //             isFinished = false;
  //             if (animation.onFinish != null) {
  //               animation.onFinish();
  //             }
  //           }
  //         }
  //         if (animations.isEmpty) {
  //           removeAnimator(i);
  //         }
  //       }
  //     }
  //   });
  //   ticker.start();
  // }

  void addAnimator(Element shape) {
    animators.add(shape);
  }

  void removeAnimator(int index) {
    animators.removeAt(index);
  }

  bool get isAnimatiing => animators.isNotEmpty;

  void stop() {
    if (ticker != null) {
      ticker.stop();
      ticker.dispose();
      ticker = null;
    }
  }

  // void stopAllAnimations([bool toEnd = true]) {
  //   for (var animator in animators) {
  //     animator.stopAnimate(toEnd);
  //   }
  //   animators.clear();
  //   renderer.repaint();
  // }

  Duration get time => current;
}
