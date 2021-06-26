import 'dart:ui';

import 'package:meta/meta.dart';

typedef Draw = void Function(Canvas);

abstract class Scene {

  Path? clip;

  int? zIndex;

  // Help to order stablely.
  int? preOrder;

  void paint(Canvas canvas) {
    _setCanvas(canvas);
    draw(canvas);
    _restoreCanvas(canvas);
  }

  void _setCanvas(Canvas canvas) {
    canvas.save();

    if (clip != null) {
      canvas.clipPath(clip!);
    }
  }

  @protected
  void draw(Canvas canvas);

  void _restoreCanvas(Canvas canvas) {
    canvas.restore();
  }
}
