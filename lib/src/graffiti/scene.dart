import 'dart:ui';

import 'package:flutter/animation.dart';

import 'element/element.dart';
import 'transition.dart';
import 'graffiti.dart';

/// A scene for graffiti to paint graphical elements.
class Scene {
  /// Creates a scnene.
  /// 
  /// You should use [Graffiti.createScene] to get a scene.
  Scene({
    required this.layer,
    required this.builtinLayer,
    this.transition,
    required TickerProvider tickerProvider,
    required this.repaint,
  }) {
    if (transition == null) {
      _controller = null;
    } else {
      _controller = AnimationController(
          vsync: tickerProvider, duration: transition!.duration);
      final animation = transition!.curve == null
          ? _controller!
          : CurvedAnimation(parent: _controller!, curve: transition!.curve!);
      animation.addListener(() {
        if (_animateElements) {
          _elements = [];
          for (var i = 0; i < _endElements!.length; i++) {
            _elements!.add(
                _endElements![i].lerpFrom(_startElements![i], animation.value));
          }
        }

        if (_animateClip) {
          _clip = _endClip!.lerpFrom(_startClip!, animation.value);
        }

        repaint();
      });
      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_animateElements) {
            _elements = _currentElements;
          }
          if (_animateClip) {
            _clip = _currentClip;
          }

          repaint();
        }
      });
    }
  }

  /// The layer index of this scene.
  final int layer;

  /// The built-in layer index of this scene.
  /// 
  /// It decides the order of scenes with same [layer].
  final int builtinLayer;

  /// The transition animation specifications of this scene.
  final Transition? transition;

  /// The previous index in [Graffiti._scenes] of this scene.
  /// 
  /// This is for stable sorting of scenes with same [layer].
  late int preIndex;

  /// The elements of current cycle.
  List<MarkElement>? _currentElements;

  /// The elements of previous cycle.
  List<MarkElement>? _preElements;

  /// The start elements in animation.
  /// 
  /// It is normalized from [_preElements].
  List<MarkElement>? _startElements;

  /// The end elements in animation.
  /// 
  /// It is normalized from [_currentElements].
  List<MarkElement>? _endElements;

  /// The elements for painting.
  /// 
  /// It is directly set if there is no animation or interpolated from [_startElements]
  /// and [_endElements] otherwise.
  List<MarkElement>? _elements;

  /// The clip of current cycle.
  PrimitiveElement? _currentClip;

  /// The clip of previous cycle.
  PrimitiveElement? _preClip;

  /// The start clip in animation.
  /// 
  /// It is normalized from [_preClip].
  PrimitiveElement? _startClip;

  /// The end clip in animation.
  /// 
  /// It is normalized from [_endClip].
  PrimitiveElement? _endClip;

  /// The clip for painting.
  /// 
  /// It is directly set if there is no animation or interpolated from [_startClip]
  /// and [_endClip] otherwise.
  PrimitiveElement? _clip;

  /// The handler to notify graffiti to repaint.
  final void Function() repaint;

  /// The animation controller of this scene if there is animation.
  late final AnimationController? _controller;

  /// Whether to animate elements.
  late bool _animateElements;

  /// Whether to animate the clip.
  late bool _animateClip;

  /// Whether there are elements to paint in current cycle.
  /// 
  /// This is for complemention elements in animation.
  bool get hasCurrent =>
      _currentElements != null && _currentElements!.isNotEmpty;

  /// Sets elements and clip of this scene.
  void set(List<MarkElement>? elements, [PrimitiveElement? clip]) {
    _animateElements = _controller != null &&
        _currentElements != null &&
        elements != null &&
        _currentElements!.length == elements.length;
    _animateClip = _controller != null && _currentClip != null && clip != null;

    _preElements = _currentElements;
    _currentElements = elements;
    if (!_animateElements) {
      _elements = elements;
    }

    _preClip = _currentClip;
    _currentClip = clip;
    if (!_animateClip) {
      _clip = clip;
    }
  }

  /// Updates this scnene.
  /// 
  /// Directly notifys graffiti to repaint if there is no animation or prepares
  /// and starts an animation otherwise.
  /// 
  /// It should only be called by graffiti.
  void update() {
    if (_animateElements) {
      final elementsPair =
          nomalizeElementList(_preElements!, _currentElements!);
      _startElements = elementsPair.first;
      _endElements = elementsPair.last;
    }

    if (_animateClip) {
      final clipPair = nomalizeElement(_preClip!, _currentClip!);
      _startClip = clipPair.first as PrimitiveElement;
      _endClip = clipPair.last as PrimitiveElement;
    }

    if (_animateElements || _animateClip) {
      _controller!.reset();
      if (transition!.repeat) {
        _controller!.repeat(reverse: transition!.repeatReverse);
      } else {
        _controller!.forward();
      }
    } else {
      // Multiple setState in one sync circle will be merged.
      repaint();
    }
  }

  /// Paints this scene.
  void paint(Canvas canvas) {
    if (_elements != null) {
      canvas.save();

      if (_clip != null) {
        if (_clip!.rotation == null) {
          canvas.clipPath(_clip!.path);
        } else {
          canvas.save();

          canvas.translate(_clip!.rotationAxis!.dx, _clip!.rotationAxis!.dy);
          canvas.rotate(_clip!.rotation!);
          canvas.translate(-_clip!.rotationAxis!.dx, -_clip!.rotationAxis!.dy);

          canvas.clipPath(_clip!.path);

          canvas.restore();
        }
      }

      for (var element in _elements!) {
        element.paint(canvas);
      }

      canvas.restore();
    }
  }

  /// Dispose this scnene.
  void dispose() => _controller?.dispose();
}
