import 'dart:ui';

import 'mark/mark.dart';
import 'graffiti.dart';

class Scene {
  Scene({
    required this.layer,
    required this.subLayer,
    required this.animate,
  });

  final int layer;

  final int subLayer;

  final bool animate;

  late int preIndex;

  ShapeMark? _currentClip;

  ShapeMark? _preClip;

  ShapeMark? _clip;

  Map<String, Mark>? _currentMarks;

  Map<String, Mark>? _preMarks;

  List<Mark>? _startFrame;

  List<Mark>? _endFrame;

  List<Mark>? _frame;

  void update(Map<String, Mark>? marks, ShapeMark? clip) {
    _preMarks = _currentMarks;
    _currentMarks = marks;
    _preClip = _currentClip;

  }

  void paint(Canvas canvas) {
    if (_frame != null) {
      canvas.save();
      if (_clip != null) {
        canvas.clipPath(_clip!.path);
      }

      for (var mark in _frame!) {
        mark.paint(canvas);
      }

      canvas.restore();
    }
  }
}
