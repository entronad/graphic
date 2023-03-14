import 'dart:ui';

import 'package:flutter/animation.dart';

import 'element/element.dart';
import 'transition.dart';

class Scene {
  Scene({
    required this.layer,
    required this.chartLayer,
    this.transition,
    required TickerProvider tickerProvider,
    required this.repaint,
  }) {
    if (transition == null) {
      _controller = null;
    } else {
      _controller = AnimationController(vsync: tickerProvider, duration: transition!.duration);
      final animation = transition!.curve == null ? _controller! : CurvedAnimation(parent: _controller!, curve: transition!.curve!);
      animation.addListener(() {
        if (_animateElements) {
          _elements = [];
          for (var i = 0; i < _endElements!.length; i++) {
            _elements!.add(_endElements![i].lerpFrom(_startElements![i], animation.value));
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

  final int layer;

  final int chartLayer;

  final Transition? transition;

  late int preIndex;

  List<MarkElement>? _currentElements;

  List<MarkElement>? _preElements;

  List<MarkElement>? _startElements;

  List<MarkElement>? _endElements;

  List<MarkElement>? _elements;

  PrimitiveElement? _currentClip;

  PrimitiveElement? _preClip;

  PrimitiveElement? _startClip;

  PrimitiveElement? _endClip;

  PrimitiveElement? _clip;

  final void Function() repaint;

  late final AnimationController? _controller;

  late bool _animateElements;

  late bool _animateClip;

  void set(List<MarkElement>? elements, [PrimitiveElement? clip]) {
    _animateElements = _controller != null && _currentElements != null && elements != null;
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

  void update() {
    if (_animateElements) {
      final elementsPair = nomalizeElementList(_preElements!, _currentElements!);
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
      repaint();
    }
  }

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

  void dispose() => _controller?.dispose();
}
