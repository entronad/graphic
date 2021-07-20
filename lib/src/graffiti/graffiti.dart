import 'dart:ui';

import 'scene.dart';

class Graffiti {
  Graffiti(Size size) : _clip = Rect.fromLTWH(
    0,
    0,
    size.width,
    size.height,
  );

  final _scenes = <Scene>[];

  Rect _clip;

  void set size(Size value) {
    _clip = Rect.fromLTWH(
      0,
      0,
      value.width,
      value.height,
    );
  }

  Graffiti add(Scene scene) {
    _scenes.add(scene);
    return this;
  }

  Graffiti sort() {
    _scenes.sort((a, b) {
      final zIndexRst = a.zIndex - b.zIndex;
      return zIndexRst != 0
        ? zIndexRst
        : a.layer - b.layer;
    });
    return this;
  }

  /// Used for CustomPainter's paint method.
  /// Won't paint outside size.
  void paint(Canvas canvas) {
    canvas.save();
    canvas.clipRect(_clip);

    for (var scene in _scenes) {
      scene.executePaint(canvas);
    }

    canvas.restore();
  }
}
