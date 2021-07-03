import 'dart:ui';

import 'scene/scene.dart';

class SceneGraph {
  final _scenes = <Scene>[];

  SceneGraph add(Scene scene) {
    _scenes.add(scene);
    return this;
  }

  SceneGraph sort() {
    _scenes.sort((a, b) {
      final zIndexRst = a.zIndex - b.zIndex;
      return zIndexRst != 0
        ? zIndexRst
        : a.layer - b.layer;
    });
    return this;
  }

  void paint(Canvas canvas) {
    for (var scene in _scenes) {
      scene.paint(canvas);
    }
  }
}
