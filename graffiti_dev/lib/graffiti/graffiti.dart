import 'package:flutter/widgets.dart';

import 'scene.dart';

/// The rendering engine.
class Graffiti {
  /// The scenes to paint.
  final _scenes = <Scene>[];

  /// Adds a scene to this graffiti.
  S add<S extends Scene>(S scene) {
    _scenes.add(scene);
    return scene;
  }

  /// Sorts [_scenes].
  ///
  /// The priority of comparing is [Scene.layer] > [Scene.layer] > [Scene.preOrder].
  void sort() {
    for (var i = 0; i < _scenes.length; i++) {
      _scenes[i].preIndex = i;
    }
    _scenes.sort((a, b) {
      final layerRst = a.layer - b.layer;
      if (layerRst != 0) {
        return layerRst;
      } else {
        final subLayerRst = a.subLayer - b.subLayer;
        if (subLayerRst != 0) {
          return subLayerRst;
        } else {
          return a.preIndex - b.preIndex;
        }
      }
    });
  }

  /// Used for CustomPainter's paint method.
  ///
  /// Paints the scenes.
  ///
  /// It is called by [CustomPainter.paint].
  void paint(Canvas canvas) {
    for (var scene in _scenes) {
      scene.paint(canvas);
    }
  }
}
