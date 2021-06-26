import 'dart:ui';

import 'scene/base.dart';

class SceneGraph {
  final _scenes = <Scene>[];

  void paint(Canvas canvas) {
    for (var scene in _scenes) {
      scene.paint(canvas);
    }
  }
}
