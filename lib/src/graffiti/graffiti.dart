import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

import 'scene.dart';

/// The rendering engine.
class Graffiti {
  /// Creates a graffiti.
  ///
  /// Because the canvas is a relative coordinate with the origin at the chart widgit's
  /// top left, the input chart [size] determins the canvas boundary.
  Graffiti(Size size)
      : _clip = Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        );

  /// The scenes to paint.
  final _scenes = <Scene>[];

  /// The painting clip.
  ///
  /// It is a rectangle of the canvas boundary.
  Rect _clip;

  /// Sets the [_clip] with the chart size.
  ///
  /// Because the canvas is a relative coordinate with the origin at the chart widgit's
  /// top left, the chart size determins the canvas boundary.
  void set size(Size value) {
    _clip = Rect.fromLTWH(
      0,
      0,
      value.width,
      value.height,
    );
  }

  /// Adds a scene to this graffiti.
  S add<S extends Scene>(S scene) {
    _scenes.add(scene);
    return scene;
  }

  /// Sorts [_scenes].
  ///
  /// The priority of comparing is [Scene.zIndex] > [Scene.layer] > [Scene.preOrder].
  void sort() {
    for (var i = 0; i < _scenes.length; i++) {
      _scenes[i].preOrder = i;
    }
    _scenes.sort((a, b) {
      final zIndexRst = a.zIndex - b.zIndex;
      if (zIndexRst != 0) {
        return zIndexRst;
      } else {
        final layerRst = a.layer - b.layer;
        if (layerRst != 0) {
          return layerRst;
        } else {
          return a.preOrder - b.preOrder;
        }
      }
    });
  }

  /// Used for CustomPainter's paint method.
  /// Won't paint outside size.
  ///
  /// Paints the scenes.
  ///
  /// It is called by [CustomPainter.paint].
  void paint(Canvas canvas) {
    canvas.save();
    canvas.clipRect(_clip);

    for (var scene in _scenes) {
      scene.paint(canvas);
    }

    canvas.restore();
  }
}
