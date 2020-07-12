import 'package:flutter/rendering.dart';

import 'group.dart';

class Painter extends CustomPainter {
  Painter(this.renderer);

  final Renderer renderer;

  @override
  void paint(Canvas canvas, Size size) {
    renderer.paint(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
    this != oldDelegate;
}

class Renderer extends Group {
  Painter _painter;

  void Function() _repaintTrigger;

  bool _mounted = false;

  Painter get painter => _painter;

  void Function() get repaintTrigger => _repaintTrigger;

  bool get mounted => _mounted;

  void mount(
    void Function() repaintTrigger,
  ) {
    _repaintTrigger = repaintTrigger;

    _painter = Painter(this);

    _mounted = true;
  }

  void repaint() {
    if (_mounted) {
      _painter = Painter(this);
      _repaintTrigger();
    }
  }
}
