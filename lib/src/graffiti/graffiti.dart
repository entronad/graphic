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
      _scenes[i].preOrder = i;
    }
    _scenes.sort((a, b) {
      final layerRst = a.layer - b.layer;
      if (layerRst != 0) {
        return layerRst;
      } else {
        final intrinsicLayerRst = a.intrinsicLayer - b.intrinsicLayer;
        if (intrinsicLayerRst != 0) {
          return intrinsicLayerRst;
        } else {
          return a.preOrder - b.preOrder;
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
