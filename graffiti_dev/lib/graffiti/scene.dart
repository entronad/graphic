import 'dart:ui';

import 'package:flutter/animation.dart';

import 'mark/mark.dart';
import 'graffiti.dart';
import 'transition.dart';

class Scene {
  Scene({
    required this.layer,
    required this.subLayer,
    this.transition,
    required TickerProvider vsync,
    required this.repaint,
  }) {
    if (transition != null) {
      _controller = AnimationController(vsync: vsync, duration: transition!.duration);
      final animation = transition!.curve == null ? _controller! : CurvedAnimation(parent: _controller!, curve: transition!.curve!);
      animation.addListener(() {
        _marks = [];
        for (var i = 0; i < _endMarks!.length; i++) {
          _marks!.add(_endMarks![i].lerpFrom(_startMarks![i], animation.value));
        }

        _clip = _endClip!.lerpFrom(_startClip!, animation.value);

        repaint();
      });
      animation.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _marks = _currentMarks;
          _clip = _currentClip;

          repaint();
        }
      });
    }
  }

  final int layer;

  final int subLayer;

  final Transition? transition;

  late int preIndex;

  List<Mark>? _currentMarks;

  List<Mark>? _preMarks;

  List<Mark>? _startMarks;

  List<Mark>? _endMarks;

  List<Mark>? _marks;

  ShapeMark? _currentClip;

  ShapeMark? _preClip;

  ShapeMark? _startClip;

  ShapeMark? _endClip;

  ShapeMark? _clip;

  final void Function() repaint;

  late final AnimationController? _controller;

  void set(List<Mark>? marks, ShapeMark? clip) {
    if (_controller == null) {
      _marks = marks;
      _clip = clip;
    } else {
      _preMarks = _currentMarks;
      _currentMarks = marks;
      _preClip = _currentClip;
      _currentClip = clip;
    }
  }

  void update() {
    if (_controller == null) {
      repaint();
    } else {
      _startMarks = [];
      _endMarks = [];
      assert(_preMarks!.length == _currentMarks!.length);
      for (var i = 0; i < _currentMarks!.length; i++) {
        final markPair = nomalizeMarks(_preMarks![i], _endMarks![i]);
        _startMarks!.add(markPair.first);
        _endMarks!.add(markPair.last);
      }

      final clipPair = nomalizeMarks(_preClip!, _currentClip!);
      _startClip = clipPair.first as ShapeMark;
      _endClip = clipPair.last as ShapeMark;

      _controller!.reset();
      if (transition!.repeat) {
        _controller!.forward();
      } else {
        _controller!.repeat(reverse: transition!.repeatReverse);
      }
    }
  }

  void paint(Canvas canvas) {
    if (_marks != null) {
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

      for (var mark in _marks!) {
        mark.paint(canvas);
      }

      canvas.restore();
    }
  }

  void dispose() => _controller?.dispose();
}
