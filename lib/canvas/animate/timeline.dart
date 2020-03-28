import 'dart:ui' show Color;

import 'package:flutter/scheduler.dart' show Ticker;
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import '../canvas_controller.dart' show CanvasController;
import '../element.dart' show Element;
import 'animation.dart' show Animation;
import '../attrs.dart' show Attrs;
import '../shape/path_command.dart' show PathCommand, AbsolutePathCommand;
import '../util/path.dart' show pathToAbsolute, fillPathByDiff, formatPath;

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
      if (toValue is Matrix4) {
        cProps[key] = (toValue - (fromValue as Matrix4)) * ratio + (fromValue as Matrix4);
        continue;
      }
      if (toValue is List<PathCommand>) {
        var toPath = pathToAbsolute(toValue);
        var fromPath = pathToAbsolute(fromValue as List<PathCommand>);
        if (toPath.length > fromPath.length) {
          fromPath = fillPathByDiff(fromPath, toPath);
          fromPath = formatPath(fromPath, toPath);
          animation.fromAttrs.pathCommands = fromPath;
          animation.toAttrs.pathCommands = fromPath;
        } else if (!animation.pathFormatted) {
          fromPath = formatPath(fromPath, toPath);
          animation.fromAttrs.pathCommands = fromPath;
          animation.toAttrs.pathCommands = fromPath;
          animation.pathFormatted = true;
        }
        final pathCommands = <AbsolutePathCommand>[];
        for (var i = 0; i < toPath.length; i++) {
          pathCommands.add(fromPath[i].lerp(toPath[i], ratio));
        }
        cProps[key] = pathCommands;
        continue;
      }
      cProps[key] = toValue;
    }
  shape.attr(cProps);
}

bool update(Element shape, Animation animation, Duration elapsed) {
  final startTime = animation.startTime;
  final delay = animation.delay;
  if (elapsed < startTime + delay || animation.paused) {
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
  Timeline(this.canvasController);

  CanvasController canvasController;

  List<Element> animators;

  Duration current;

  Ticker ticker;

  void initTicker() {
    var isFinished = false;
    Element shape;
    List<Animation> animations;
    Animation animation;
    ticker = canvasController.cfg.tickerProvider.createTicker((elapsed) {
      current = elapsed;
      if (animators.isNotEmpty) {
        for (var i = animators.length - 1; i >= 0; i--) {
          shape = animators[i];
          if (shape.destroyed) {
            removeAnimator(i);
            continue;
          }
          if (!shape.isAnimatePaused()) {
            animations = shape.cfg.animations;
            for (var j = animations.length - 1; j >= 0; i--) {
              animation = animations[j];
              isFinished = update(shape, animation, elapsed);
              if (isFinished) {
                animations.removeAt(j);
                isFinished = false;
                if (animation.onFinish != null) {
                  animation.onFinish();
                }
              }
            }
          }
          if (animations.isEmpty) {
            removeAnimator(i);
          }
        }
        final autoDraw = canvasController.cfg.autoDraw;
        if (!autoDraw) {
          canvasController.draw();
        }
      }
    });
  }

  void addAnimator(Element shape) {
    animators.add(shape);
  }

  void removeAnimator(int index) {
    animators.removeAt(index);
  }

  bool get isAnimatiing => animators.isNotEmpty;

  void stop() {

  }

  void stopAllAnimations([bool toEnd = true]) {
    animators.forEach((animator) {
      animator.stopAnimate(toEnd);
    });
    animators = [];
    canvasController.draw();
  }

  Duration get time => current;
}
