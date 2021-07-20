import 'dart:ui';

import 'package:meta/meta.dart';

typedef Draw = void Function(Canvas);

abstract class Scene {
  Scene([this.clip]);

  Path? clip;

  int zIndex = 0;

  int get layer;

  // Help to order stablely.
  int? preOrder;

  void executePaint(Canvas canvas) {
    canvas.save();
    if (clip != null) {
      canvas.clipPath(clip!);
    }

    paint(canvas);

    canvas.restore();
  }

  /// Subclass override this method.
  @protected
  void paint(Canvas canvas);
}
